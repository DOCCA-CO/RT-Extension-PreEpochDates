use strict;
use warnings;

use inc::Module::Install;

RTx('RT-Extension-PreEpochDates');
all_from 'lib/RT/Extension/PreEpochDates.pm';
author 'DOCCA';
requires_rt '5.0.0';
sign;
WriteAll;