from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import CustomUser, Route, Booking, SeatReservation


@admin.register(CustomUser)
class CustomUserAdmin(BaseUserAdmin):
    list_display = ('username', 'email', 'first_name', 'last_name', 'role', 'is_verified', 'created_at')
    list_filter = ('role', 'is_verified', 'created_at')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Información Adicional', {
            'fields': ('phone', 'role', 'is_verified', 'created_at')
        }),
    )
    readonly_fields = ('created_at',)


@admin.register(Route)
class RouteAdmin(admin.ModelAdmin):
    list_display = ('id', 'route_name', 'route_number', 'start_point', 'end_point', 'fare', 'is_active', 'created_at')
    list_filter = ('is_active', 'created_at')
    search_fields = ('route_name', 'route_number')
    readonly_fields = ('created_at',)


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'route', 'num_seats', 'total_price', 'status', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('user__username', 'user__email', 'route__route_name')
    readonly_fields = ('created_at', 'confirmed_at')


@admin.register(SeatReservation)
class SeatReservationAdmin(admin.ModelAdmin):
    list_display = ('id', 'booking', 'seat_number', 'reserved_at')
    list_filter = ('reserved_at',)
    search_fields = ('booking__id',)
    readonly_fields = ('reserved_at',)