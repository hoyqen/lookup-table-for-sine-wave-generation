%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  writen by wang bin long
%%  data: 2018.04.25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,x0,str,ts] = CORDIC(t,x,u,flag)
switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;          %初始化状态
  case 2,
    sys = mdlUpdate(t,x,u);                      %离散状态更新
  case 3,
    sys=mdlOutputs(t,x,u);                       %计算输出
  case {1 4 9},
    sys= [];
  otherwise
    sys =[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,x0,str,ts]=mdlInitializeSizes
sizes = simsizes;
sizes.NumContStates  = 0; %模块中连续状态变量的个数
sizes.NumDiscStates  = 1; %模块中离散状态变量的个数
sizes.NumOutputs     = 2; %模块中输出变量的个数
sizes.NumInputs      = 1; %模块输入变量的个数
sizes.DirFeedthrough = 1; %模块中是否存在直接贯通
sizes.NumSampleTimes = 1; %模块采样时间个数，至少一个
sys = simsizes(sizes);    %设置完成后赋值给sys输出
x0  = 0;                  %离散变量的初始值
str = [];                 %预留 直接不管就行
ts  = [-1 0];             %设置采样频率
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = mdlUpdate(t,x,u)
fs = 750000;             %这里的采样频率根据实际需要进行修改
temp = x(1);
if (temp + u(1)/fs*2*pi) >= 2*pi;   %相位累加，超过2*pi,清零
    temp = 0;
else
    temp = temp+u(1)/fs*2*pi;
end
sys = temp;             %跟新离散状态变量x(1)的值
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = mdlOutputs(t,x,u)
xx = zeros(29,1);
yy = zeros(29,1);
zz = zeros(29,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
phase_in = x(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if( phase_in >= pi*3/2)
    phase_in_reg = phase_in - pi*3/2;
elseif( phase_in >= pi )
    phase_in_reg = phase_in - pi;
elseif(phase_in >= pi/2)
    phase_in_reg = phase_in - pi/2;
else
    phase_in_reg = phase_in;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xx(1,1) = 0.60725;                            %对CORDIC迭代之后的数据进行补偿
yy(1,1) = 0;
zz(1,1) = phase_in_reg;
for j = 1:1:28
    if( zz(j,1) > 0)
        xx(j+1,1) = xx(j,1) - yy(j,1)*2^(-j+1);
        yy(j+1,1) = yy(j,1) + xx(j,1)*2^(-j+1);
        zz(j+1,1) = zz(j,1) -atan(2^(-j+1));
    else
        xx(j+1,1) = xx(j,1) + yy(j,1)*2^(-j+1);
        yy(j+1,1) = yy(j,1) - xx(j,1)*2^(-j+1);
        zz(j+1,1) = zz(j,1) + atan(2^(-j+1));
    end     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if( phase_in >= pi*3/2)
   sin_out = -xx(29,1);
   cos_out = yy(29,1);
elseif( phase_in >= pi )
   sin_out = -yy(29,1);
   cos_out = -xx(29,1);
elseif(phase_in >= pi/2)
   sin_out = xx(29,1);
   cos_out = -yy(29,1);
else
   sin_out = yy(29,1);
   cos_out = xx(29,1);
end
sys = [cos_out sin_out];          %跟新系统的输出信号的值



