#! /usr/local/epd/bin/python
__author__ = "Shantanu H. Joshi"
__copyright__ = "Copyright 2015, Shantanu H. Joshi Ahmanson-Lovelace Brain Mapping Center, \
                 University of California Los Angeles"
__email__ = "s.joshi@g.ucla.edu"


from distutils.core import setup

setup(
    name='surftools',
    version='0.1dev',
    packages=['surftools'],
    license='TBD',
    exclude_package_data={'': ['.gitignore','.idea']},
    scripts=['bin/register_surface.py',
             ],
#    long_description=open('README.txt').read(),
)
