pragma Ada_2012;

with STM32.Device;
with STM32.GPIO; use STM32.GPIO;
with Ada.Real_Time;

package body Bipolar_Stepper_Motor_Package is

   procedure Initialize (Motor                   : in out Bipolar_Stepper_Motor;
                         Step_Pin                : in STM32.GPIO.GPIO_Point;
                         Dir_Pin                 : in STM32.GPIO.GPIO_Point;
                         Microstepping           : in Type_Micro_Stepping := Full_Step;
                         Delay_Sec_Between_Steps : in Standard.Duration := 0.0001) is

      Pins_Motor : constant STM32.GPIO.GPIO_Points := (Step_Pin , Dir_Pin);

   begin
      Motor.Step_Pin := Step_Pin;
      Motor.Dir_Pin := Dir_Pin;
      Motor.Microstepping := Microstepping;
      Motor.Delay_Sec_Between_Steps := Delay_Sec_Between_Steps;

      STM32.Device.Enable_Clock (Pins_Motor);

      STM32.GPIO.Configure_IO
        (Points            => Pins_Motor,
         Config            => (Mode_Out,
                               Resistors   => Floating,
                               Output_Type => Push_Pull,
                               Speed       => Speed_100MHz));

   end;

   procedure Set_Direction (Motor             : in out Bipolar_Stepper_Motor;
                            Direction         : in Type_Direction := Clockwise) is
   begin

      if Direction = Clockwise then
         Motor.Dir_Pin.Set;
      else
         Motor.Dir_Pin.Clear;
      end if;

   end Set_Direction;

   ----------
   -- Step --
   ----------
   --  rotation of one step
   procedure Step (Motor     : in out Bipolar_Stepper_Motor;
                   Direction : in Type_Direction := Clockwise) is
   begin

      Motor.Set_Direction (Direction);

      Motor.Step_Pin.Set;
      Motor.Step_Pin.Clear;
      delay (Motor.Delay_Sec_Between_Steps);

   end;

   --  rotation of multiple steps
   procedure Step (Motor            : in out Bipolar_Stepper_Motor;
                   Number_Of_Steps  : in Positive;
                   Direction        : in Type_Direction := Clockwise) is
   begin

      Motor.Set_Direction (Direction);

      for Index in 1 .. Number_Of_Steps loop
         Motor.Step_Pin.Set;
         Motor.Step_Pin.Clear;
         delay (Motor.Delay_Sec_Between_Steps);
      end loop;

   end;

   --  rotation of an angle in degree
   procedure Step_Angle (Motor                : in out Bipolar_Stepper_Motor;
                         Angle                : in Degrees ;
                         Steps_Per_Revolution : in Positive := 200 ;  --  NEMA 17
                         Direction            : in Type_Direction := Clockwise) is
   begin

      Motor.Step (Number_Of_Steps => Positive ( Float (Steps_Per_Revolution * (case Motor.Microstepping is
                     when Full_Step => 1,
                     when Half_Step => 2,
                     when Stepping_1_4_Step  => 4,
                     when Stepping_1_8_Step  => 8,
                     when Stepping_1_16_Step => 16)) * Float (Angle) / 360.0),
                  Direction       => Direction);

   end;

end Bipolar_Stepper_Motor_Package;
