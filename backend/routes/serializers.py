from django.db import transaction
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Route, Booking, SeatReservation
from django.utils import timezone


User = get_user_model()


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password2 = serializers.CharField(write_only=True, min_length=8)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'first_name', 'last_name', 'phone', 'password', 'password2', 'role']
        extra_kwargs = {
            'role': {'required': False},
        }
    
    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Este email ya está registrado.")
        return value
    
    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("Este usuario ya existe.")
        if len(value) < 3:
            raise serializers.ValidationError("El usuario debe tener al menos 3 caracteres.")
        return value
    
    def validate(self, data):
        if data['password'] != data.pop('password2'):
            raise serializers.ValidationError({"password": "Las contraseñas no coinciden."})
        return data
    
    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            phone=validated_data.get('phone', ''),
            password=validated_data['password'],
            role=validated_data.get('role', 'visitor')
        )
        return user


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'phone', 'role', 'is_verified', 'created_at']
        read_only_fields = ['id', 'created_at']


class UserDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'phone', 'role', 'is_verified', 'created_at']
        read_only_fields = ['id', 'created_at', 'role']


class RouteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Route
        fields = [
            'id', 'route_name', 'route_number', 'start_point', 'end_point',
            'fare', 'estimated_duration', 'description', 'is_active', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class SeatReservationSerializer(serializers.ModelSerializer):
    class Meta:
        model = SeatReservation
        fields = ['id', 'booking', 'seat_number', 'reserved_at']
        read_only_fields = ['id', 'reserved_at']


class BookingSerializer(serializers.ModelSerializer):
    seats = SeatReservationSerializer(many=True, read_only=True)
    user_detail = UserSerializer(source='user', read_only=True)
    route_detail = RouteSerializer(source='route', read_only=True)
    
    class Meta:
        model = Booking
        fields = ['id', 'user', 'user_detail', 'route', 'route_detail', 'num_seats', 'total_price', 'status', 'seats', 'created_at', 'confirmed_at']
        read_only_fields = ['id', 'created_at', 'confirmed_at']
    
    def validate_num_seats(self, value):
        if value < 1:
            raise serializers.ValidationError("Debe reservar al menos 1 asiento.")
        if value > 14:
            raise serializers.ValidationError("No puede reservar más de 14 asientos.")
        return value


class BookingCreateSerializer(serializers.ModelSerializer):
    seat_numbers = serializers.ListField(child=serializers.IntegerField(), write_only=True)
    
    class Meta:
        model = Booking
        fields = ['route', 'num_seats', 'total_price', 'seat_numbers']
    
    def validate_seat_numbers(self, value):
        if not value:
            raise serializers.ValidationError("Debe proporcionar números de asientos.")
        
        for seat in value:
            if seat < 1 or seat > 14:
                raise serializers.ValidationError(f"Asiento {seat} inválido (1-14).")
        
        if len(value) != len(set(value)):
            raise serializers.ValidationError("No puede seleccionar el mismo asiento dos veces.")
        
        return value
    
    def validate(self, data):
        route = data.get('route')
        seat_numbers = data.get('seat_numbers', [])
        if route and seat_numbers:
            reserved = SeatReservation.objects.filter(
                booking__route=route,
                seat_number__in=seat_numbers,
                booking__status__in=['pending', 'confirmed']
            )
            if reserved.exists():
                raise serializers.ValidationError("Uno o más asientos ya están reservados.")
        return data
    
    def create(self, validated_data):
        seat_numbers = validated_data.pop('seat_numbers')
        user = self.context['request'].user
        
        with transaction.atomic():
            booking = Booking.objects.create(
                user=user,
                **validated_data
            )
            SeatReservation.objects.bulk_create([
                SeatReservation(booking=booking, seat_number=seat_num)
                for seat_num in seat_numbers
            ])
        
        return booking