package RT::Extension::PreEpochDates;

use strict;
use warnings;

our $VERSION = '0.01';

require RT::Date;
require RT::Extension::PreEpochDates::Date;

RT->AddJavaScript('datepicker-fix.js');

1;