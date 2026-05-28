from django.contrib import admin
from .models import Employee, Meeting, LeavingRequests, Profile, Department

admin.site.register(Employee)
admin.site.register(Meeting)
admin.site.register(LeavingRequests)
admin.site.register(Profile)
admin.site.register(Department)
