with Bipolar_Stepper_Motor_Package; use Bipolar_Stepper_Motor_Package;
with Ada.Real_Time;
with STM32.GPIO;

package Bipolar_Stepper_Motor_Task_Package is

	--  type Bipolar_Stepper_Motor_Task is limited private;

	procedure Initialize (Step_Pin                : in STM32.GPIO.GPIO_Point;
							  Dir_Pin                 : in STM32.GPIO.GPIO_Point;
							  Microstepping           : in Type_Micro_Stepping := Full_Step;
							  Delay_Sec_Between_Steps : in Standard.Duration := 0.00001;  --  minimum delay between step elsewhere step don't run (10us NEMA 17)
							  Steps_Per_Revolution    : in Positive := 200;
							  Direction               : in Type_Direction := Clockwise); --  NEMA 17

	procedure Start (Rpm : in Float);
	procedure Stop;
	procedure Set_Direction (Direction : in Type_Direction);


private

	type Motor_State_Type is (Stopped , Running);

	protected type Protected_Motor_Controller_Type is
		entry Start (Period : in Ada.Real_Time.Time_Span);
		entry Stop;
		entry Continue;
		entry Set_Direction (Direction : in Type_Direction);
		function Get_Period return Ada.Real_Time.Time_Span;
		function Get_Status return Motor_State_Type;
	private
		Motor_State : Motor_State_Type := Stopped;
		Period_Task : Ada.Real_Time.Time_Span;
	end Protected_Motor_Controller_Type;

	type Bipolar_Stepper_Motor_Task is limited
		record
			Motor                   : Bipolar_Stepper_Motor_Package.Bipolar_Stepper_Motor;
			Motor_Controller        : Protected_Motor_Controller_Type;
			Microstepping           : Type_Micro_Stepping := Full_Step;
			Steps_Per_Revolution    : Positive := 200;
		end record;

end Bipolar_Stepper_Motor_Task_Package;
