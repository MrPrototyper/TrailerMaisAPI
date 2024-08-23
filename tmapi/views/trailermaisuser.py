from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from tmapi.models.TrailerMaisUser import TrailerMaisUser as MyUser
from tmapi.serializers import TrailerMaisUserSerializer
from django.shortcuts import get_object_or_404

class TrailerMaisUser(APIView):
    def get_permissions(self):        
        if self.request.method == 'POST':
            # Allow anyone to create a user (i.e., to register)
            return [AllowAny()]
        elif self.request.method == 'GET':
            # Only authenticated users can retrieve the list of users
            return [IsAuthenticated()]
        return super().get_permissions()
    
    def get(self, request):       
        users = MyUser.objects.all()
        serializer = TrailerMaisUserSerializer(users, many=True)
        return Response(serializer.data)
    
    def post(self, request):        
        serializer = TrailerMaisUserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
class GetByEmail(APIView):
    def post(self, request):
        print(request)
        email = request.data.get('email')    

        application = get_object_or_404(MyUser, email=email)
        serializer = TrailerMaisUserSerializer(application)
        return Response(serializer.data)
    

    