#!/bin/bash

sed -e "s%my_arg_1%$1%g" < run_hisat2.lsf | bsub
