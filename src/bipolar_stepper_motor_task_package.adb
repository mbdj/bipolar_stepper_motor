with Ada.Real_Time; use Ada.Real_Time;

package body Bipolar_Stepper_Motor_Task_Package is

	Motor : Bipolar_Stepper_Motor_Task;

	procedure Initialize (Step_Pin                : in STM32.GPIO.GPIO_Point;
							  Dir_Pin                 : in STM32.GPIO.GPIO_Point;
							  Microstepping           : in Type_Micro_Stepping := Full_Step;
							  Delay_Sec_Between_Steps : in Standard.Duration := 0.00001;  --  minimum delay between step elsewhere step don't run (10us NEMA 17)
							  Steps_Per_Revolution    : in Positive := 200;
							  Direction               : in Type_Direction := Clockwise) is --  NEMA 17
	begin
		Motor.Motor.Initialize (Step_Pin                => Step_Pin,
								  Dir_Pin                 => Dir_Pin,
								  Microstepping           => Microstepping,
								  Delay_Sec_Between_Steps => Delay_Sec_Between_Steps,
								  Steps_Per_Revolution    => Steps_Per_Revolution,
								  Direction               => Direction);

		Motor.Microstepping  := Microstepping;
		Motor.Steps_Per_Revolution := Steps_Per_Revolution;
	end;


	protected body Protected_Motor_Controller_Type  is
		entry Start (Period : Ada.Real_Time.Time_Span) when Motor_State = Stopped is
		begin
			Motor_State := Running;
			Period_Task := Period;
		end Start;

		entry Stop when Motor_State = Running is
		begin
			Motor_State := Stopped;
		end Stop;

		-- waits until Motor_State = Running
		entry Continue when Motor_State = Running is
		begin
			null;
		end Continue;

		entry Set_Direction (Direction : in Type_Direction) when Motor_State = Stopped is
		begin
			Motor.Motor.Set_Direction (Direction => Direction);
		end;

		function Get_Period return Ada.Real_Time.Time_Span is (Period_Task);
		function Get_Status return Motor_State_Type is (Motor_State);

	end Protected_Motor_Controller_Type;



	procedure Start (Rpm : in Float) is
	begin

		Motor.Motor_Controller.Start (Period =>
											 Ada.Real_Time.Milliseconds (Integer (60000.0 /
												(Float (Motor.Steps_Per_Revolution
													  * (case Motor.Microstepping is
															 when Full_Step          => 1,
															 when Half_Step          => 2,
															 when Stepping_1_4_Step  => 4,
															 when Stepping_1_8_Step  => 8,
															 when Stepping_1_16_Step => 16))
													  * Rpm))
											  )
										 );
	end;


	procedure Stop is
	begin
		Motor.Motor_Controller.Stop;
	end;


	procedure Set_Direction (Direction : in Type_Direction) is
	begin
		Motor.Motor_Controller.Set_Direction (Direction => Direction);
	end;



	task Motor_Task;

	task body Motor_Task is
		Next_Release : Ada.Real_Time.Time;
	begin

		Motor.Motor_Controller.Continue;

		loop

			Next_Release := Ada.Real_Time.Clock + Motor.Motor_Controller.Get_Period;
			delay until Next_Release;

			Motor.Motor.Step;
			Motor.Motor_Controller.Continue;

		end loop;

	end;


end Bipolar_Stepper_Motor_Task_Package;
