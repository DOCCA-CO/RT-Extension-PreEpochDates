# RT-Extension-PreEpochDates

## Overview

This plugin fixes an issue in Request Tracker where Date-type custom fields could not store dates earlier than 1970-01-01.

In affected RT versions, attempting to save a date prior to January 1, 1970 resulted in the value being rejected or stored incorrectly due to Unix epoch limitations. This extension updates the date validation and parsing logic to allow valid historical dates, enabling organizations to manage legacy records without date restrictions.

## Fixed Issue

### Problem
* Date custom fields rejected or miscalculated dates on or before 1969-12-31.
* Historical records (e.g., birth dates, legacy contract dates) could not be saved correctly.

### Solution
* Extended date handling logic to seamlessly support dates prior to 1970-01-01.
* Preserved standard date parsing and validation for modern dates.
* Fully backward compatible with existing custom field definitions (no database migrations required).

### Examples
The following dates are now accepted and stored correctly:
* `1969-12-31`
* `1956-10-23`
* `1900-01-01`

---

## RT Version Compatibility

* Tested on Request Tracker **5.0.x** 

---

## Installation

Add this line to your RT_SiteConfig.pm configuration file:

Plugin('RT::Extension::PreEpochDates');

```bash
perl Makefile.PL
make
make install

Clear your mason cache and restart your web server:

rm -rf /opt/rt5/var/mason_data/obj/*
systemctl restart apache2 # or systemctl restart php-fpm / spawn-fcgi / webserver
