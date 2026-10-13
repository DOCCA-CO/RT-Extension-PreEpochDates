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

* Requires Request Tracker **5.0.0** or later.
* Tested on Request Tracker **5.0.x**.

---

## Installation

Install the extension from its source directory on the RT server. If it is not
already available, install the build prerequisite first:

```sh
cpanm Module::Install::RTx
```

Set `RTHOME` to the RT installation directory, then generate and install the
extension. `make install` must be run with permission to write to RT:

```sh
export RTHOME=/opt/rt
perl Makefile.PL
make
make install
```

Enable the plugin by adding this line to `RT_SiteConfig.pm`:

```perl
Plugin('RT::Extension::PreEpochDates');
```

Then clear RT's Mason cache and restart the web server. The RT installation
path and service name vary by deployment; for example:

```sh
rm -rf /opt/rt/var/mason_data/obj/*
systemctl restart apache2
```

## Tests

The integration test needs an installed RT tree and its configuration. Set
`RTHOME` to that tree and run:

```sh
RTHOME=/opt/rt prove -v xt/date.t
```

No database migration is required.
