from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils.translation import gettext_lazy as _

class TrailerMaisUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):        
        extra_fields.setdefault('is_superuser', True)

        return self.create_user(email, password, **extra_fields)

class TrailerMaisUser(AbstractBaseUser, PermissionsMixin):
    class Meta:
        app_label = 'tmapi'
    email = models.EmailField(_('email address'), unique=True)        
    name = models.CharField(max_length=30, blank=True)
    photo = models.CharField(max_length=25, blank=True)    
    is_active = models.BooleanField(default=True)    
    date_joined = models.DateTimeField(auto_now_add=True)

    objects = TrailerMaisUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.email