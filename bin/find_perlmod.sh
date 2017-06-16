#!/bin/bash
find $(perl -e 'print join $/, @INC,' ) -name "*.pm"
