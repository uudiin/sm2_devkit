#!/bin/bash

#keyctl padd asymmetric "IMA-SM2" %:.secondary_trusted_keys < cert.der

keyctl padd asymmetric "IMA-SM2" %:.ima < cert.der

keyctl show %:.secondary_trusted_keys
keyctl show %:.ima
