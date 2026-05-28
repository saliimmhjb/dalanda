from django.urls import path
from .views import (
    employees_list,
    employee_detail,
    departments_list,
    meetings_list,
    leaving_requests_list,
    ai_chat_assistant,
    update_leave_status,
    update_meeting_status,
)
from .views import register, login


urlpatterns = [
    path("employees/", employees_list),
    path("employees/<int:id>/", employee_detail),
    path("departments/", departments_list),
    path("register/", register),
    path("login/", login),
    path("meetings/", meetings_list),
    path("leaves/", leaving_requests_list),
    path("ai/chat/", ai_chat_assistant),
    path("meetings/<int:id>/status/", update_meeting_status),
    path("leaves/<int:id>/status/", update_leave_status),
]
