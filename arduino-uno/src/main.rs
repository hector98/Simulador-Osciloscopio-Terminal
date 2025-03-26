#![no_std]
#![no_main]

use panic_halt as _;
use arduino_hal::prelude::_embedded_hal_serial_Read;

#[arduino_hal::entry]
fn main() -> ! {
    let dp = arduino_hal::Peripherals::take().unwrap();
    let pins = arduino_hal::pins!(dp);

    // Habilitar ADC
    let mut adc = arduino_hal::Adc::new(dp.ADC, Default::default());

    // Puertos Analogicos
    let ldr = pins.a0.into_analog_input(&mut adc);
    let filtro = pins.a1.into_analog_input(&mut adc);

    let mut led = pins.d8.into_output();

    // Comunicacion Serial
    let mut serial = arduino_hal::default_serial!(dp, pins, 57600);

    loop {
        let signal = ldr.analog_read(&mut adc) as u16;
        let filtro_value = filtro.analog_read(&mut adc) as u16;

        ufmt::uwrite!(&mut serial, "{}:{}\r\n", signal, filtro_value);
        let data = serial.read();

        if data == core::prelude::v1::Ok(b'1') {
            led.set_high();
        } else {
            led.set_low();
        }

        arduino_hal::delay_ms(1);
    }

}
