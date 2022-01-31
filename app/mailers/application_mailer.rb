# frozen_string_literal: true

class ApplicationMailer < MandrillMailer::TemplateMailer
  default from: 'no-reply@bridj.com'
  BOOKING_SUCCESS_EMAIL_TEMPLATES = {
    'bridj' => 'admin-booking-success-au',
    'jbird' => 'jbird-booking-confirmed-au'
  }

  BOOKING_CANCELLED_EMAIL_TEMPLATES = {
    'bridj' => 'admin-booking-cancel-au',
    'jbird' => 'jbird-booking-cancelled-au'
  }

  WELCOME_EMAIL_TEMPLATES = {
    'bridj' => 'admin-welcome-email-au',
    'jbird' => 'jbird-welcome-au'
  }

  def send_email(data)
    mandrill_mail(data)
  end

  def booking_success(traveler_id, booking_id, price, currency)
    traveler = Traveler.find(traveler_id)
    booking = Booking.find(booking_id)

    origin = booking.pickup
    time_zone = booking.zone.time_zone

    booking_time = booking.created_at.in_time_zone(time_zone)
    travel_time = booking.pickup_scheduled_at.in_time_zone(time_zone)

    send_email(
      template: BOOKING_SUCCESS_EMAIL_TEMPLATES[booking.app_identify],
      subject: I18n.t("user_mailer.#{booking.app_identify}.booking_success_subject"),
      to: { email: traveler.email, name: traveler.first_name },
      vars: {
        'FNAME' => traveler.first_name,
        'LNAME' => traveler.last_name,
        'ORIGIN' => origin.name,
        'TRIP_PRICE' => format_price(price, currency),
        'DATE' => I18n.l(travel_time, format: :trip_list),
        'TIME' => I18n.l(travel_time, format: :time_only),
        'BOOKING_DATE' => I18n.l(booking_time, format: :date_and_time),
        'PAYMENT_METHOD' => format_payment_method(booking, traveler)
      },
      inline_css: true
    )
  end

  def format_price(price, currency)
    ActiveSupport::NumberHelper.number_to_currency(price, unit: (currency == 'AUD' ? '$' : currency))
  end

  def format_payment_method(booking, _traveler)
    case booking.payment_method
    when PaymentMethod::CARD
      'Credit Card'
    when PaymentMethod::COMP
      'Complimentary'
    when PaymentMethod::OPALPAY
      'OpalPay'
    else
      booking.payment_method.camelize
    end
  end

  def send_welcome_email(traveler_id)
    user = Traveler.find(traveler_id)

    send_email(
      template: WELCOME_EMAIL_TEMPLATES[user.app_identify],
      subject: I18n.t("user_mailer.#{user.app_identify}.send_welcome_email_subject"),
      to: { email: user.email, name: user.first_name },
      vars: { 'FNAME' => user.first_name },
      inline_css: true
    )
  end

  def cancelled_booking(booking_id)
    booking = Booking.find(booking_id)
    traveler = booking.traveler
    price_in_cents = booking.price
    currency = booking.zone.currency
    time_zone = booking.zone.time_zone
    booking_time = booking.created_at
    travel_time = booking.pickup_scheduled_at
    origin = booking.origin.name

    send_email(
      template: BOOKING_CANCELLED_EMAIL_TEMPLATES[booking.app_identify],
      subject: I18n.t("user_mailer.#{booking.app_identify}.cancelled_booking_subject"),
      to: { email: traveler.email, name: traveler.first_name },
      vars: {
        'FNAME' => traveler.first_name,
        'LNAME' => traveler.last_name,
        'ORIGIN' => origin,
        'TRIP_PRICE' => format_price(price_in_cents, currency),
        'DATE' => I18n.l(travel_time.in_time_zone(time_zone), format: :trip_list),
        'TIME' => I18n.l(travel_time.in_time_zone(time_zone), format: :time_only),
        'BOOKING_DATE' => I18n.l(booking_time.in_time_zone(time_zone), format: :date_and_time)
      },
      inline_css: true
    )
  end
end
