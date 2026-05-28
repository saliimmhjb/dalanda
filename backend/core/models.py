from django.db import models
from django.contrib.auth.models import User


class Department(models.Model):
    name = models.CharField(max_length=100)
    # The chief is the N+1. We use a string reference 'Employee' to avoid circular import errors
    chief = models.OneToOneField(
        "Employee",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="led_department",
    )

    def __str__(self):
        return self.name


class Profile(models.Model):
    ROLE_CHOICES = [("HR", "HR Manager"), ("Employee", "Employee")]
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default="Employee")

    def __str__(self):
        return f"{self.user.username} - {self.role}"


class Employee(models.Model):
    GRADE_CHOICES = [
        ("Junior", "Junior"),
        ("Senior", "Senior"),
        ("Expert", "Expert"),
    ]

    user = models.OneToOneField(
        User,
        related_name="employee_data",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
    )
    name = models.CharField(max_length=100)
    email = models.EmailField()
    position = models.CharField(max_length=100)
    department = models.ForeignKey(
        Department,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="members",
    )

    # --- NEW FROM ADVISOR ---
    grade = models.CharField(max_length=20, choices=GRADE_CHOICES, default="Junior")
    is_chief = models.BooleanField(default=False)

    # Specific balances for different leave types
    annual_leave_balance = models.IntegerField(default=22)
    sick_leave_balance = models.IntegerField(default=15)

    phone = models.CharField(max_length=20, null=True, blank=True)
    performance = models.CharField(max_length=10, default="0%")
    projects = models.CharField(max_length=4, default="0")
    tenure = models.CharField(max_length=20, default="New")
    image = models.ImageField(upload_to="employees/", null=True, blank=True)
    hire_date = models.DateField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.grade})"

    def save(self, *args, **kwargs):
        # Automatically set predefined balance based on Grade if this is a new record
        if not self.pk:
            if self.grade == "Senior":
                self.annual_leave_balance = 25
            elif self.grade == "Expert":
                self.annual_leave_balance = 30
        super().save(*args, **kwargs)


class Meeting(models.Model):
    title = models.CharField(max_length=200)
    type = models.CharField(max_length=100)
    time = models.CharField(max_length=50, default="10:00 AM")
    color_hex = models.CharField(max_length=7, default="#B84CFF")
    status = models.CharField(max_length=20, default="Pending")
    requested_by = models.CharField(max_length=100, null=True, blank=True)
    target_department = models.ForeignKey(
        Department, on_delete=models.CASCADE, null=True, blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class LeavingRequests(models.Model):
    TYPE_CHOICES = [
        ("Annual Leave", "Annual"),
        ("Sick Leave", "Sick"),
        ("Personal Leave", "Personal"),
        ("Maternity", "Maternity"),
    ]
    employee_name = models.CharField(max_length=100)
    employee = models.ForeignKey(
        Employee, on_delete=models.CASCADE, null=True, blank=True
    )
    type = models.CharField(
        max_length=100, choices=TYPE_CHOICES, default="Annual Leave"
    )
    reason = models.TextField(null=True, blank=True)
    start_date = models.CharField(max_length=30, null=True, blank=True)
    end_date = models.CharField(max_length=30, null=True, blank=True)
    duration = models.IntegerField(default=1)
    status = models.CharField(max_length=15, default="Pending")
    icon_data = models.CharField(max_length=20, default="pause")

    def __str__(self):
        return f"{self.employee_name} - {self.type}"
