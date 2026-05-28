from rest_framework import serializers
from .models import Department, Employee, Meeting, LeavingRequests


class DepartmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Department
        fields = "__all__"


class EmployeeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employee
        fields = "__all__"


class MeetingSerializer(serializers.ModelSerializer):
    target_department = serializers.PrimaryKeyRelatedField(
        queryset=Department.objects.all(), required=False, allow_null=True
    )

    class Meta:
        model = Meeting
        fields = "__all__"


class LeavingRequestsSerializer(serializers.ModelSerializer):
    employee = serializers.PrimaryKeyRelatedField(
        queryset=Employee.objects.all(), required=False, allow_null=True
    )
    type = serializers.ChoiceField(
        choices=LeavingRequests.TYPE_CHOICES,
        required=True,
    )

    class Meta:
        model = LeavingRequests
        fields = "__all__"
