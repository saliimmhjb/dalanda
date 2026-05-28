from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from rest_framework.authtoken.models import Token
from django.db.models import Q

from .models import Employee, Meeting, LeavingRequests, Profile, Department
from .serializers import (
    DepartmentSerializer,
    EmployeeSerializer,
    MeetingSerializer,
    LeavingRequestsSerializer,
)
from .user_serializers import RegisterSerializer

import ollama
from .ai_utils import get_hr_database_context


def _get_user_role(user):
    try:
        return user.profile.role
    except Exception:
        return "Employee"


@api_view(["POST"])
@permission_classes([AllowAny])
def login(request):
    email = request.data.get("email", "").strip().lower()
    password = request.data.get("password", "")

    user = authenticate(username=email, password=password)

    if user is not None:
        token, created = Token.objects.get_or_create(user=user)
        profile, created = Profile.objects.get_or_create(
            user=user, defaults={"role": "Employee"}
        )

        employee = Employee.objects.filter(email=user.email).first()
        image_url = ""
        if employee and employee.image:
            image_url = request.build_absolute_uri(employee.image.url)

        return Response(
            {
                "token": token.key,
                "username": user.first_name if user.first_name else user.username,
                "role": profile.role,
                "email": user.email,
                "image": image_url,
                "leave_balance": (
                    employee.annual_leave_balance + employee.sick_leave_balance
                )
                if employee
                else 0,
            }
        )

    return Response({"error": "Invalid credentials"}, status=401)


@api_view(["POST"])
@permission_classes([AllowAny])
def register(request):
    """
    Used only by HR to onboard new employees.
    Creates User, Profile, and Employee record in one go.
    """
    serializer = RegisterSerializer(data=request.data)
    role = request.data.get("role", "Employee")

    if serializer.is_valid():
        # 1. Create Login User
        user = serializer.save()

        # 2. Create Role Profile
        Profile.objects.create(user=user, role=role)

        # 3. Create Employee Identity
        Employee.objects.create(
            user=user,
            name=user.first_name,
            email=user.email,
            position="New Joiner",
            department=None,  # HR will update this via Edit Profile
            performance="0%",
            tenure="NEW",
            annual_leave_balance=15,
            sick_leave_balance=15,
        )

        token = Token.objects.create(user=user)
        return Response({"token": token.key, "username": user.first_name, "role": role})

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET", "POST"])
@permission_classes([IsAuthenticated])
def employees_list(request):
    user_role = _get_user_role(request.user)

    if request.method == "GET":
        if user_role == "HR":
            # HR sees everyone
            employees = Employee.objects.all()
        else:
            # Employee only sees people in their department
            user_emp = Employee.objects.filter(user=request.user).first()
            if user_emp and user_emp.department:
                employees = Employee.objects.filter(department=user_emp.department)
            else:
                employees = Employee.objects.filter(user=request.user)

        serializer = EmployeeSerializer(employees, many=True)
        return Response(serializer.data)

    elif request.method == "POST":
        # HR Adding Employee via Form
        if user_role != "HR":
            return Response({"error": "Only HR can add employees"}, status=403)

        serializer = EmployeeSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET", "PUT", "DELETE"])
@permission_classes([IsAuthenticated])
def employee_detail(request, id):
    try:
        employee = Employee.objects.get(id=id)
    except Employee.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == "GET":
        serializer = EmployeeSerializer(employee)
        return Response(serializer.data)

    elif request.method == "PUT":
        serializer = EmployeeSerializer(employee, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == "DELETE":
        employee.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def departments_list(request):
    departments = Department.objects.all()
    serializer = DepartmentSerializer(departments, many=True)
    return Response(serializer.data)


@api_view(["GET", "POST"])
@permission_classes([IsAuthenticated])
def meetings_list(request):
    user_emp = Employee.objects.filter(user=request.user).first()

    if request.method == "GET":
        if _get_user_role(request.user) == "HR":
            meetings = Meeting.objects.all().order_by("created_at")
        else:
            # Targeted Visibility: Dept meetings OR general meetings
            if user_emp and user_emp.department:
                meetings = Meeting.objects.filter(
                    Q(target_department=user_emp.department)
                    | Q(target_department__isnull=True)
                ).order_by("created_at")
            else:
                meetings = Meeting.objects.filter(
                    target_department__isnull=True
                ).order_by("created_at")

        serializer = MeetingSerializer(meetings, many=True)
        return Response(serializer.data)

    elif request.method == "POST":
        serializer = MeetingSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


def _parse_leave_duration(value):
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        cleaned = value.strip()
        if cleaned.isdigit():
            return int(cleaned)
        # Try to parse day range like 01/05/24 to 03/05/24
        parts = cleaned.replace("-", "/").split(" to ")
        if len(parts) == 2:
            try:
                from datetime import datetime

                start = datetime.strptime(parts[0].strip(), "%d/%m/%y")
                end = datetime.strptime(parts[1].strip(), "%d/%m/%y")
                delta = (end - start).days + 1
                return max(1, delta)
            except Exception:
                pass
        return 1
    return 1


def _find_employee_by_name(name):
    if not name:
        return None
    return Employee.objects.filter(name__iexact=name.strip()).first()


@api_view(["GET", "POST"])
@permission_classes([IsAuthenticated])
def leaving_requests_list(request):
    if request.method == "GET":
        if _get_user_role(request.user) == "HR":
            requests = LeavingRequests.objects.all()
        else:
            # Employees only see their own requests
            user_emp = Employee.objects.filter(user=request.user).first()
            if user_emp:
                requests = LeavingRequests.objects.filter(employee=user_emp)
            else:
                requests = LeavingRequests.objects.none()

        serializer = LeavingRequestsSerializer(requests, many=True)
        return Response(serializer.data)

    elif request.method == "POST":
        data = request.data.copy()
        if _get_user_role(request.user) == "Employee":
            user_emp = Employee.objects.filter(user=request.user).first()
            if user_emp:
                data["employee"] = user_emp.pk
                data["employee_name"] = user_emp.name
        else:
            employee_name = data.get("employee_name", "")
            employee_obj = _find_employee_by_name(employee_name)
            if employee_obj:
                data["employee"] = employee_obj.pk

        data["duration"] = _parse_leave_duration(data.get("duration", 1))
        data.setdefault("status", "Pending")

        serializer = LeavingRequestsSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["PATCH"])
@permission_classes([IsAuthenticated])
def update_leave_status(request, id):
    try:
        leave = LeavingRequests.objects.get(id=id)
        current_user = request.user
        user_role = _get_user_role(current_user)

        # Identify the manager (n+1)
        # The manager is the Chief of the department the employee belongs to
        employee_requesting = leave.employee
        manager_of_dept = (
            employee_requesting.department.chief
            if employee_requesting.department
            else None
        )

        is_hr = user_role == "HR"
        is_manager = manager_of_dept and manager_of_dept.user == current_user

        # 🛡️ New Validation Rule: Only HR or Manager can approve
        if not (is_hr or is_manager):
            return Response(
                {"error": "You are not authorized to validate this leave."}, status=403
            )

        new_status = request.data.get("status")

        if new_status == "Approved" and leave.status != "Approved":
            # Deduction Logic based on type
            if leave.type == "Sick Leave":
                employee_requesting.sick_leave_balance -= leave.duration
            else:
                employee_requesting.annual_leave_balance -= leave.duration
            employee_requesting.save()

        leave.status = new_status
        leave.save()
        return Response(
            {"message": f"Leave {leave.status} by {'HR' if is_hr else 'Manager'}"}
        )
    except Exception as e:
        return Response({"error": str(e)}, status=400)


@api_view(["PATCH"])
@permission_classes([IsAuthenticated])
def update_meeting_status(request, id):
    try:
        meeting = Meeting.objects.get(id=id)
        meeting.status = request.data.get("status")
        meeting.save()
        return Response({"message": f"Meeting {meeting.status}"})
    except Meeting.DoesNotExist:
        return Response(status=404)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def ai_chat_assistant(request):
    user_message = request.data.get("message", "")
    try:
        system_rules = get_hr_database_context()
        response = ollama.chat(
            model="llama3.2",
            messages=[
                {"role": "system", "content": system_rules},
                {"role": "user", "content": user_message},
            ],
            options={"temperature": 0, "num_predict": 200},
        )
        return Response({"reply": response["message"]["content"].strip()})
    except Exception as e:
        return Response({"reply": "AI brain offline."}, status=500)
