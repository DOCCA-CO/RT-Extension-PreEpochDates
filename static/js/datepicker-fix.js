(function () {
    var originalInitDatePicker = window.initDatePicker;

    window.initDatePicker = function (elem) {
        var result = originalInitDatePicker.apply(this, arguments);
        var container = elem || jQuery('body');
        container.find('.datepicker.hasDatepicker').datepicker('option', 'yearRange', 'c-80:c+30');
        return result;
    };

    jQuery(function () {
        jQuery('.datepicker.hasDatepicker').datepicker('option', 'yearRange', 'c-80:c+30');
    });
}());