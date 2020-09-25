#!/bin/bash

keyctl padd asymmetric "sm2_cert" %:.secondary_trusted_keys < cert.der

keyctl show %:.secondary_trusted_keys
