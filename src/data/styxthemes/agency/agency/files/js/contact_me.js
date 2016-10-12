/*
    This script was originally part of David Millers (https://github.com/davidtmiller)
    Bootstrap theme "Freelancer" add some functionality to the contact form.

    Licensed under the Apache License 2.0. For more information take a look at the orignal
    repository unde https://github.com/IronSummitMedia/startbootstrap-freelancer.
*/

$(function() {

    $("input,textarea").jqBootstrapValidation({
        preventSubmit: true,
        submitError: function($form, event, errors) {
            // additional error messages or events
        },

        filter: function() {
            return $(this).is(":visible");
        },
    });

    $("a[data-toggle=\"tab\"]").click(function(e) {
        e.preventDefault();
        $(this).tab("show");
    });
});

/*When clicking on Full hide fail/success boxes */
$('#name').focus(function() {
    $('#success').html('');
});
