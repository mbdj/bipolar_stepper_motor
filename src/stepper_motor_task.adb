with STM32.GPIO; use STM32.GPIO;
with STM32.Device; use STM32.Device;

with Bipolar_Stepper_Motor_Task_Package; use Bipolar_Stepper_Motor_Task_Package;
with Bipolar_Stepper_Motor_Package;

procedure Stepper_Motor_Task is
begin

	Initialize (Step_Pin => STM32.Device.PA0,
				 Dir_Pin => STM32.Device.PA1);

	loop

		delay (1.0);
		Set_Direction (Direction => Bipolar_Stepper_Motor_Package.Clockwise);
		Start (Rpm => 10.0);
		delay (3.0);

		Stop;
		delay (1.0);

		Set_Direction (Direction => Bipolar_Stepper_Motor_Package.Anti_Clockwise);
		Start (Rpm => 30.0);
		delay (5.0);

		Stop;

	end loop;


end Stepper_Motor_Task;
