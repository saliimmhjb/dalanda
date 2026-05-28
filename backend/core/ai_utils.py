from .models import Employee, Meeting, LeavingRequests


def get_hr_database_context():
    employees = Employee.objects.all()
    meetings = Meeting.objects.all()
    leaves = LeavingRequests.objects.all()

    data_summary = "OFFICIAL COMPANY RECORDS:\n\n"

    data_summary += "--- STAFF DIRECTORY ---\n"
    for e in employees:
        data_summary += (
            f"Employee: '{e.name}' | Role: '{e.position}' | "
            f"Dept: '{e.department}' | Performance: '{e.performance}' | "
            f"Projects: {e.projects}\n"
        )

    data_summary += "\n--- CALENDAR ---\n"
    for m in meetings:
        data_summary += f"Meeting: '{m.title}' at {m.time}. Status: {getattr(m, 'status', 'Approved')}\n"

    data_summary += "\n--- LEAVE REQUESTS ---\n"
    for l in leaves:
        data_summary += (
            f"Request by: '{l.employee_name}' | Type: {l.type} | Status: {l.status}\n"
        )

    system_instruction = f"""
    You are 'Dalanda', the official AI HR Assistant.
    
    INSTRUCTIONS:
    1. Answer questions ONLY using the 'OFFICIAL COMPANY RECORDS' provided below.
    2. You can compare numbers (like Performance or Projects) to find the 'top' or 'most' employees.
    3. If asked about the 'most projects', look at the 'Projects' value for every employee and identify the highest.
    4. Be professional and very concise.

    {data_summary}
    """
    return system_instruction
