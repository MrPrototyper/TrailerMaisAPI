from rest_framework import serializers
from tmapi.models.TrailerMaisUser import TrailerMaisUser

class TrailerMaisUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrailerMaisUser
        fields = ['id', 'email', 'name', 'photo', 'is_active', 'date_joined', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):        
        return TrailerMaisUser.objects.create_user(**validated_data)