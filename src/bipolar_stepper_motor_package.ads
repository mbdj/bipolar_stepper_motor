--
--  Mehdi
--  03/09/2023
--
--  Driver for a bipolar stepper motor and driver (eg : driver DRV8825 + motor NEMA 17)
--

with STM32.GPIO;

package Bipolar_Stepper_Motor_Package is

   type Bipolar_Stepper_Motor is tagged limited private;
   type Type_Direction is (Clockwise, Anti_Clockwise);
   type Type_Micro_Stepping is (Full_Step, Half_Step, Stepping_1_4_Step, Stepping_1_8_Step, Stepping_1_16_Step);

   procedure Initialize (Motor                   : in out Bipolar_Stepper_Motor;
                         Step_Pin                : in STM32.GPIO.GPIO_Point;
                         Dir_Pin                 : in STM32.GPIO.GPIO_Point;
                         Microstepping           : in Type_Micro_Stepping := Full_Step;
                         Delay_Sec_Between_Steps : in Standard.Duration := 0.00001;  --  minimum delay between step elsewhere step don't run
                         Steps_Per_Revolution    : in Positive := 200); --  NEMA 17

   ----------
   -- Step --
   ----------
   --  rotation of one step
   -- nb : Span_Delay : 1 ms minimum else the motor can't rotate
   procedure Step (Motor           : in out Bipolar_Stepper_Motor;
                   Direction       : in Type_Direction := Clockwise);

   --  rotation of multiple steps
   procedure Step (Motor            : in out Bipolar_Stepper_Motor;
                   Number_Of_Steps  : in Positive;
                   Direction        : in Type_Direction := Clockwise);

   procedure Step (Motor            : in out Bipolar_Stepper_Motor;
                   Number_Of_Steps  : in Positive;
                   Rpm              : in Float;
                   Direction        : in Type_Direction := Clockwise);

   procedure Step_loop (Motor            : in out Bipolar_Stepper_Motor;
                   Rpm              : in Float;
                   Direction        : in Type_Direction := Clockwise);

      --  rotation of an angle in degree
      type Degrees is digits 5 range 0.0 .. 360.0;
      procedure Step_Angle (Motor     : in out Bipolar_Stepper_Motor;
                            Angle     : in Degrees ;
                            Direction : in Type_Direction := Clockwise);

      procedure Step_Angle (Motor     : in out Bipolar_Stepper_Motor;
                            Angle     : in Degrees ;
                            Rpm       : in Float;
                            Direction : in Type_Direction := Clockwise) ;

      procedure Set_Direction (Motor     : in out Bipolar_Stepper_Motor;
                               Direction : in Type_Direction := Clockwise);

   private

      type Bipolar_Stepper_Motor is tagged limited
         record
            Step_Pin                  :  STM32.GPIO.GPIO_Point;
            Dir_Pin                   :  STM32.GPIO.GPIO_Point;
            Microstepping             :  Type_Micro_Stepping := Full_Step;
            Delay_Sec_Between_Steps   : Standard.Duration := 0.00001;
            Steps_Per_Revolution      : Positive := 200 ;  --  NEMA 17
         end record;

   end Bipolar_Stepper_Motor_Package;
