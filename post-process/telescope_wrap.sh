#!/bin/bash

sed -e "s%my_arg_1%$1%g" -e "s%my_arg_2%$2%g" < run_telescope.lsf | bsub
