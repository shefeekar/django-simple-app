from django.contrib import admin

from .models import User, Country, City, CountryLanguage

admin.site.register(User)
admin.site.register(City)
admin.site.register(Country)
admin.site.register(CountryLanguage)
