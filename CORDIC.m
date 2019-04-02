%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  writen by wang bin long
%%  data: 2018.04.25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,x0,str,ts] = CORDIC(t,x,u,flag)
switch flag,
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;          %��ʼ��״̬
  case 2,
    sys = mdlUpdate(t,x,u);                      %��ɢ״̬����
  case 3,
    sys=mdlOutputs(t,x,u);                       %�������
  case {1 4 9},
    sys= [];
  otherwise
    sys =[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,x0,str,ts]=mdlInitializeSizes
sizes = simsizes;
sizes.NumContStates  = 0; %ģ��������״̬�����ĸ���
sizes.NumDiscStates  = 1; %ģ������ɢ״̬�����ĸ���
sizes.NumOutputs     = 2; %ģ������������ĸ���
sizes.NumInputs      = 1; %ģ����������ĸ���
sizes.DirFeedthrough = 1; %ģ�����Ƿ����ֱ�ӹ�ͨ
sizes.NumSampleTimes = 1; %ģ�����ʱ�����������һ��
sys = simsizes(sizes);    %������ɺ�ֵ��sys���
x0  = 0;                  %��ɢ�����ĳ�ʼֵ
str = [];                 %Ԥ�� ֱ�Ӳ��ܾ���
ts  = [-1 0];             %���ò���Ƶ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = mdlUpdate(t,x,u)
fs = 750000;             %����Ĳ���Ƶ�ʸ���ʵ����Ҫ�����޸�
temp = x(1);
if (temp + u(1)/fs*2*pi) >= 2*pi;   %��λ�ۼӣ�����2*pi,����
    temp = 0;
else
    temp = temp+u(1)/fs*2*pi;
end
sys = temp;             %������ɢ״̬����x(1)��ֵ
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
xx(1,1) = 0.60725;                            %��CORDIC����֮������ݽ��в���
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
sys = [cos_out sin_out];          %����ϵͳ������źŵ�ֵ



