from django.db import models
from django.core.validators import MinValueValidator
from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError


class CustomUser(AbstractUser):
    ROLE_CHOICES = [
        ('admin', 'Administrador'),
        ('visitor', 'Visitante'),
    ]
    
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True)
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='visitor')
    is_verified = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"


class Route(models.Model):
    route_name = models.CharField(max_length=100)
    route_number = models.CharField(max_length=50)
    start_point = models.CharField(max_length=100)
    end_point = models.CharField(max_length=100)
    fare = models.IntegerField(validators=[MinValueValidator(0)])
    estimated_duration = models.IntegerField()
    description = models.TextField(blank=True, default='')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.route_name} ({self.route_number})"


class Booking(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pendiente'),
        ('confirmed', 'Confirmada'),
        ('cancelled', 'Cancelada'),
    ]
    
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='bookings')
    route = models.ForeignKey(Route, on_delete=models.CASCADE, related_name='bookings')
    num_seats = models.IntegerField(validators=[MinValueValidator(1)])
    total_price = models.IntegerField(validators=[MinValueValidator(0)])
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    confirmed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Reserva {self.id} - {self.user.username}"


class SeatReservation(models.Model):
    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name='seats')
    seat_number = models.IntegerField(validators=[MinValueValidator(1)])
    reserved_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ('booking', 'seat_number')
    
    def __str__(self):
        return f"Asiento {self.seat_number} - Reserva {self.booking.id}"