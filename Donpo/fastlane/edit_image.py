#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import logging
import argparse
from PIL import Image  # pip install Pillow

logging.basicConfig(format='%(asctime)s [%(levelname)s] %(message)s', level=logging.INFO)  # INFO DEBUG


def resize(path, out_path, x_size):
    img = Image.open(path)
    (x, y) = img.size
    y_s = int(y * x_size / x)  # calc height based on standard width
    out = img.resize((x_size, y_s), Image.ANTIALIAS)  # resize image with high-quality
    out.save(out_path)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--path", type=str, help="image path, example: -p '/home/cheung/Downloads/love.jpg'")
    parser.add_argument("-x", "--x_size", type=int, help="image x size, example: -x_size 200")
    parser.add_argument("-o", "--out_path", type=str, help="image out path, example: -out_path '/home/cheung/Downloads/love.jpg'")
    args = parser.parse_args()

    resize(args.path, args.out_path, args.x_size)
