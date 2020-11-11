#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec  6 18:23:14 2019

@author: harshilpaliwal
"""

import csv
import pandas as pd


def main():
    opencsv()
    
def opencsv():
    csvfile = "/Users/harshilpaliwal/Programming/Python/ARM Assignment/test.csv"
    fileData = pd.read_csv(csvfile)
    fileData.head()
    print(fileData)