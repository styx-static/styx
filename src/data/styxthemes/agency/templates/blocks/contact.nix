{ templates, lib, ... }:
with lib;
normalTemplate (data: {
  content = templates.blocks.basic (data // {
    content = ''
      <div class="row">
        <div class="col-lg-12">
          <form  action="${data.action}" method="POST" name="sentMessage" id="contactForm" novalidate>
            <div class="row">
              <div class="col-md-6">
                <div class="form-group">
                  <input type="text" class="form-control" placeholder="${data.name.text or "Your name *"}" name="name" required data-validation-required-message="${data.name.warning or "Please enter your name."}">
                  <p class="help-block text-danger"></p>
                </div>
                <div class="form-group">
                  <input type="email" class="form-control" placeholder="${data.email.text or "Your Email *"}" name="email" required data-validation-required-message="${data.email.warning or "Please enter your email address."}">
                  <p class="help-block text-danger"></p>
                </div>
                <div class="form-group">
                  <input type="tel" class="form-control" placeholder="${data.phone.text or "Your Phone *"}" name="phone" required data-validation-required-message="${data.phone.warning or "Please enter your phone number."}">
                  <p class="help-block text-danger"></p>
                </div>
              </div>
              <div class="col-md-6">
                <div class="form-group">
                  <textarea class="form-control" placeholder="${data.message.text or "Your Message *"}" name="message" required data-validation-required-message="${data.message.warning or "Please enter a message."}"></textarea>
                  <p class="help-block text-danger"></p>
                </div>
              </div>
              <div class="clearfix"></div>
              <div class="col-lg-12 text-center">
                <div id="success"></div>
                <button type="submit" class="btn btn-xl">${data.buttonText or "Send message"}</button>
              </div>
            </div>
          </form>
        </div>
      </div>
    '';
  });
  extraJS = [
    { src = templates.url "/js/jqBootstrapValidation.js"; }
    { src = templates.url "/js/contact_me.js"; }
  ];
  extraCSS = { href = templates.url "/css/contact.css"; };
})
