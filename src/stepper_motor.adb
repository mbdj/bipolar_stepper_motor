with STM32.GPIO; use STM32.GPIO;
with STM32.Device; use STM32.Device;

with Bipolar_Stepper_Motor_Package; use Bipolar_Stepper_Motor_Package;

package body Stepper_Motor is

   Moteur : Bipolar_Stepper_Motor;

   task body Motor_Task is

   begin

      Moteur.Initialize (Step_Pin      => STM32.Device.PA0,
                         Dir_Pin       => STM32.Device.PA1,
                         Microstepping => Full_Step);

      loop
         Moteur.Step (Number_Of_Steps => 200,
                      Direction       => Clockwise);
         delay (1.0);

         Moteur.Step (Number_Of_Steps => 100,
                      Direction       => Anti_Clockwise);
         delay (1.0);

         Moteur.Step_Angle (Angle     => 90.0);
         delay (1.0);

         Moteur.Step_Angle (Angle     => 180.0,
                            Direction => Anti_Clockwise);
         delay (1.0);

         Moteur.Step_Angle (Angle     => 360.0);
         delay (1.0);

         Moteur.Step_Angle (Angle     => 180.0,
                            Direction => Anti_Clockwise);
         delay (1.0);
      end loop;

   end Motor_Task;

end Stepper_Motor;
