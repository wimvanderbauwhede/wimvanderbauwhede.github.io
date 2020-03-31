import urllib2

r = urllib2.urlopen('https://abinbev.energylab.be/Account/Register')
r2 = r.read()
print r2
