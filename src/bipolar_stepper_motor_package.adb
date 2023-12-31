pragma Ada_2012;

with STM32.Device;
with STM32.GPIO; use STM32.GPIO;
with Ada.Real_Time; use Ada.Real_Time;

package body Bipolar_Stepper_Motor_Package is

   procedure Initialize (Motor                   : in out Bipolar_Stepper_Motor;
                         Step_Pin                : in STM32.GPIO.GPIO_Point;
                         Dir_Pin                 : in STM32.GPIO.GPIO_Point;
                         Microstepping           : in Type_Micro_Stepping := Full_Step;
                         Delay_Sec_Between_Steps : in Standard.Duration := 0.00001;
                         Steps_Per_Revolution    : in Positive := 200) is

      Pins_Motor : constant STM32.GPIO.GPIO_Points := (Step_Pin , Dir_Pin);

   begin
      Motor.Step_Pin := Step_Pin;
      Motor.Dir_Pin := Dir_Pin;
      Motor.Microstepping := Microstepping;
      Motor.Delay_Sec_Between_Steps := Delay_Sec_Between_Steps;
      Motor.Steps_Per_Revolution := Steps_Per_Revolution;

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

   --  rotation of multiple steps
   procedure Step (Motor            : in out Bipolar_Stepper_Motor;
                   Number_Of_Steps  : in Positive;
                   Rpm              : in Float;
                   Direction        : in Type_Direction := Clockwise) is

      Period       : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (Integer (60000.0 /
                                                                                     (Float (Motor.Steps_Per_Revolution
                                                                                        * (case Motor.Microstepping is
                                                                                             when Full_Step          => 1,
                                                                                             when Half_Step          => 2,
                                                                                             when Stepping_1_4_Step  => 4,
                                                                                             when Stepping_1_8_Step  => 8,
                                                                                             when Stepping_1_16_Step => 16))
                                                                                        * Rpm))
                                                                                    );
      Next_Release : Ada.Real_Time.Time;
   begin

      Motor.Set_Direction (Direction);


      Next_Release := Ada.Real_Time.Clock;

      for Index in 1 .. Number_Of_Steps loop
         Motor.Step_Pin.Set;
         Motor.Step_Pin.Clear;

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;

   end;


   procedure Step_Loop (Motor            : in out Bipolar_Stepper_Motor;
                        Rpm              : in Float;
                        Direction        : in Type_Direction := Clockwise) is

      Period       : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (Integer (60000.0 /
                                                                                     (Float (Motor.Steps_Per_Revolution
                                                                                        * (case Motor.Microstepping is
                                                                                             when Full_Step          => 1,
                                                                                             when Half_Step          => 2,
                                                                                             when Stepping_1_4_Step  => 4,
                                                                                             when Stepping_1_8_Step  => 8,
                                                                                             when Stepping_1_16_Step => 16))
                                                                                        * Rpm))
                                                                                    );
      Next_Release : Ada.Real_Time.Time;
   begin

      Motor.Set_Direction (Direction);


      Next_Release := Ada.Real_Time.Clock;

      loop
         Motor.Step_Pin.Set;
         Motor.Step_Pin.Clear;

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;

   end;


   --  rotation of an angle in degree
   procedure Step_Angle (Motor                : in out Bipolar_Stepper_Motor;
                         Angle                : in Degrees ;
                         Direction            : in Type_Direction := Clockwise) is
   begin

      Motor.Step (Number_Of_Steps => Positive ( Float (Motor.Steps_Per_Revolution * (case Motor.Microstepping is
                     when Full_Step          => 1,
                     when Half_Step          => 2,
                     when Stepping_1_4_Step  => 4,
                     when Stepping_1_8_Step  => 8,
                     when Stepping_1_16_Step => 16)) * Float (Angle) / 360.0),
                  Direction       => Direction);

   end;


   procedure Step_Angle (Motor                : in out Bipolar_Stepper_Motor;
                         Angle                : in Degrees ;
                         Rpm                  : in Float;
                         Direction            : in Type_Direction := Clockwise) is
   begin

      Motor.Step (Number_Of_Steps => Positive ( Float (Motor.Steps_Per_Revolution * (case Motor.Microstepping is
                     when Full_Step          => 1,
                     when Half_Step          => 2,
                     when Stepping_1_4_Step  => 4,
                     when Stepping_1_8_Step  => 8,
                     when Stepping_1_16_Step => 16)) * Float (Angle) / 360.0),
                  Rpm             => Rpm,
                  Direction       => Direction);

   end;

end Bipolar_Stepper_Motor_Package;
