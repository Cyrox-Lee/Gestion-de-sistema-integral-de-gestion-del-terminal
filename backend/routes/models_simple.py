from django.db import models
from django.core.validators import MinValueValidator


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
