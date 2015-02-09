#!/usr/bin/env python

"""This file defines the registration methods.
"""
__author__ = "Shantanu H. Joshi"
__copyright__ = "Copyright 2015, Shantanu H. Joshi Ahmanson-Lovelace Brain Mapping Center, \
                 University of California Los Angeles"
__email__ = "s.joshi@g.ucla.edu"

import sys
import numpy as np
import math


def procrustes(src, tgt):

    Nsrc = src.shape[0]
    Ntgt = tgt.shape[0]
    reg = []

    if Nsrc != Ntgt:
        sys.stdout.write('Two inputs should have the same size')
        return reg

    #Translate src
    src_center = np.mean(src,0)
    src -= np.tile(src_center,(Nsrc,1))

    #Scale src
    src_scale = np.linalg.norm(src,'fro')
    src /= src_scale

    print src_center, src_scale

    #Translate tgt
    tgt_center = np.mean(tgt,0)
    tgt -= np.tile(tgt_center,(Nsrc,1))

    #Scale tgt
    tgt_scale = np.linalg.norm(tgt,'fro')
    tgt /= tgt_scale

    print tgt_center, tgt_scale
    U, D, V= np.linalg.svd(np.dot(src.transpose(),tgt))

    R = np.dot(U, V)
    if np.linalg.det(R) < 0.0:
        # R does not constitute right handed system
        R -= np.outer(U[:, 2], V[2, :]*2.0)

    print R
    reg = src.copy()
    reg = np.dot(reg,R)
    reg *= tgt_scale
    reg += tgt_center

    return reg


def procrustes_scale(src, tgt):

    Nsrc = src.shape[0]
    Ntgt = tgt.shape[0]
    reg = []

    #Translate src
    src_center = np.mean(src,0)
    src -= np.tile(src_center,(Nsrc,1))

    #Scale src
    src_scale = np.linalg.norm(src,'fro')
    src /= src_scale

    print src_center, src_scale

    #Translate tgt
    tgt_center = np.mean(tgt,0)
    tgt -= np.tile(tgt_center,(Ntgt,1))

    #Scale tgt
    tgt_scale = np.linalg.norm(tgt,'fro')
    tgt /= tgt_scale

    print tgt_center, tgt_scale

    reg = src.copy()
    reg *= tgt_scale
    reg += tgt_center

    return reg

