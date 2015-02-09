#!/usr/bin/env python

"""This program registers the input surface (source) to target
"""
__author__ = "Shantanu H. Joshi"
__copyright__ = "Copyright 2015, Shantanu H. Joshi Ahmanson-Lovelace Brain Mapping Center, \
                 University of California Los Angeles"
__email__ = "s.joshi@g.ucla.edu"

import argparse
from surftools import register
import sys
from shapeio import surfio
import traceback


def main():

    parser = argparse.ArgumentParser(description='This program registers the source surface to the target.')
    parser.add_argument('src', help='source surface')
    parser.add_argument('tgt', help='target surface')
    parser.add_argument('reg_out', help='registered source surface')
    parser.add_argument('-method', help='method  [procrustes,procrustes-scale]', required=False, default='procrustes-scale')

    args = parser.parse_args()
    register_surface(args.src, args.tgt, args.reg_out, args.method)


def register_surface(src, tgt, reg_out, method):

    try:
        src_coords, src_faces, src_attributes, isMultilevelUCF = surfio.readsurface_new(src)
        tgt_coords, tgt_faces, tgt_attributes, isMultilevelUCF = surfio.readsurface_new(tgt)
        reg_coords = src_coords  # Initialize reg_coords
        if method == 'procrustes':
            reg_coords = register.procrustes(src_coords, tgt_coords)

        if method == 'procrustes-scale':
            reg_coords = register.procrustes_scale(src_coords, tgt_coords)

        surfio.writesurface_new(reg_out, reg_coords, src_faces, src_attributes)

    except:
        sys.stdout.write("Something went wrong. Please send this error message to the developers.")
        sys.stdout.write(sys.exc_info()[0])

        sys.stdout.write(traceback.print_exc(file=sys.stdout))

        pass

if __name__ == '__main__':
    main()

