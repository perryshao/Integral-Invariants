clear all
%% for HDM05 dataset
global DATA_FOLDER
DATA_FOLDER = 'c3d_data/figure_body/';
% CLASS_NUM = 1;
% file_ext = '.c3d';
% folder_content = dir(DATA_FOLDER);
% class_num = size(folder_content,1);
% class_num = class_num-2;
% class_array = 1:class_num;
% K=randperm(class_num);
% CLASS_SELECTED = class_array(K(1:CLASS_NUM));

RANK = 'RANK';LANK = 'LANK';RKNE = 'RKNE';
LKNE = 'LKNE';T10 = 'T10';C7 = 'C7';
RFHD = 'RFHD';LSHO = 'LSHO';RSHO = 'RSHO';
LELB = 'LELB';RELB = 'RELB';LWRA = 'LWRA';
RWRA = 'RWRA';LFWT = 'LFWT';RFWT = 'RFWT';
STRN = 'STRN';

% RANK = '16';
% LANK = '17';
% RKNE = '14';
% LKNE = '15';
% T10 = '7';
% C7 = '3';
% RFHD = '20';
% LSHO = '2';
% RSHO = '1';
% LELB = '9';
% RELB = '8';
% LWRA = '22';
% RWRA = '10';
% LFWT = '6';
% RFWT = '5';
% STRN = '4';
%% for MHAD dataset
% DATA_FOLDER = 'c3d_data_MHAD/';
% RANK = 'MK041';
% LANK = 'MK033';
% RKNE = 'MK039';
% LKNE = 'MK031';
% T10 = 'MK005';
% C7 = 'MK006';
% RFHD = 'MK001';
% LSHO = 'MK012';
% RSHO = 'MK020';
% LELB = 'MK014';
% RELB = 'MK022';
% LWRA = 'MK017';
% RWRA = 'MK025';
% LFWT = 'MK029';
% RFWT = 'MK036';
% STRN = 'MK009';
%% load targets of joints
% random_seed=rand(1,5);
% markers = {RANK,LANK,RKNE,LKNE,T10,C7,RFHD,LSHO,RSHO,STRN,...
%            LELB,RELB,LWRA,RWRA,LFWT,RFWT};
% load_c3d_bat(markers,random_seed,CLASS_SELECTED,DATA_FOLDER);
%% load RANK joint
if exist([RANK '.mat'],'file')
    load ([RANK '.mat']);
else
    load_c3d(RANK);
    load ([RANK '.mat']);
end
%% load LANK joint
if exist([LANK '.mat'],'file')
    load ([LANK '.mat']);
else
    load_c3d(LANK);
    load ([LANK '.mat']);
end

%% load RKNE joint
if exist([RKNE '.mat'],'file')
    load ([RKNE '.mat']);
else
    load_c3d(RKNE);
    load ([RKNE '.mat']);
end

%% load LKNE joint
if exist([LKNE '.mat'],'file')
    load ([LKNE '.mat']);
else
    load_c3d(LKNE);
    load ([LKNE '.mat']);
end

%% load T10 joint
if exist([T10 '.mat'],'file')
    load ([T10 '.mat']);
else
    load_c3d(T10);
    load ([T10 '.mat']);
end
%% load C7 joint
if exist([C7 '.mat'],'file')
    load ([C7 '.mat']);
else
    load_c3d(C7);
    load ([C7 '.mat']);
end
%% load STRN joint
if exist([STRN '.mat'],'file')
    load ([STRN '.mat']);
else
    load_c3d(STRN);
    load ([STRN '.mat']);
end
%% load RWRA joint
if exist([RFHD '.mat'],'file')
    load ([RFHD '.mat']);
else
    load_c3d(RFHD);
    load ([RFHD '.mat']);
end
%% load LSHO joint
if exist([LSHO '.mat'],'file')
    load ([LSHO '.mat']);
else
    load_c3d(LSHO);
    load ([LSHO '.mat']);
end
%% load RSHO joint
if exist([RSHO '.mat'],'file')
    load ([RSHO '.mat']);
else
    load_c3d(RSHO);
    load ([RSHO '.mat']);
end
%% load LELB joint
if exist([LELB '.mat'],'file')
    load ([LELB '.mat']);
else
    load_c3d(LELB);
    load ([LELB '.mat']);
end

%% load RELB joint
if exist([RELB '.mat'],'file')
    load ([RELB '.mat']);
else
    load_c3d(RELB);
    load ([RELB '.mat']);
end

%% load LWRA joint
if exist([LWRA '.mat'],'file')
    load ([LWRA '.mat']);
else
    load_c3d(LWRA);
    load ([LWRA '.mat']);
end

%% load RWRA joint
if exist([RWRA '.mat'],'file')
    load ([RWRA '.mat']);
else
    load_c3d(RWRA);
    load ([RWRA '.mat']);
end

%% load RFWT joint
if exist([RFWT '.mat'],'file')
    load ([RFWT '.mat']);
else
    load_c3d(RFWT);
    load ([RFWT '.mat']);
end

%% load LFWT joint
if exist([LFWT '.mat'],'file')
    load ([LFWT '.mat']);
else
    load_c3d(LFWT);
    load ([LFWT '.mat']);
end
%% preprocess and descriptor computation
% preprocess('RANK');
% preprocess('LANK');
% preprocess('RKNE');
% preprocess('LKNE');
% preprocess('C7');
% preprocess('T10');
% preprocess('LSHO');
% preprocess('RSHO');
% preprocess('LELB');
% preprocess('RELB');
% preprocess('LWRA');
% preprocess('RWRA');
% preprocess('RFHD');
%%  get relative descriptions of LWRA-LELB for database
load ([LWRA '.mat']);
LWRA=TRAJDB;
load ([LELB '.mat']);
LELB=TRAJDB;
load ([LSHO '.mat']);
LSHO=TRAJDB;
load ([C7 '.mat']);
C7=TRAJDB;
load ([T10 '.mat']);
T10=TRAJDB;
load ([STRN '.mat']);
STRN=TRAJDB;
load ([RWRA '.mat']);
RWRA=TRAJDB;
load ([RELB '.mat']);
RELB=TRAJDB;
load ([RSHO '.mat']);
RSHO=TRAJDB;
load ([LKNE '.mat']);
LKNE=TRAJDB;
load ([LANK '.mat']);
LANK=TRAJDB;
load ([RKNE '.mat']);
RKNE=TRAJDB;
load ([RANK '.mat']);
RANK=TRAJDB;
load ([RFHD '.mat']);
RFHD=TRAJDB;
load ([RFWT '.mat']);
RFWT=TRAJDB;
load ([LFWT '.mat']);
LFWT=TRAJDB;
i=1;% define the i-class motion
frames=size(TRAJDB{2,i},1);
%% figure the joint of beginning frame using RED point
figure(1);
plot3(RANK{2,i}(1,1),RANK{2,i}(1,2),RANK{2,i}(1,3),'rs','markersize',10),hold on;
plot3(RKNE{2,i}(1,1),RKNE{2,i}(1,2),RKNE{2,i}(1,3),'rs','markersize',10),hold on;

plot3(LANK{2,i}(1,1),LANK{2,i}(1,2),LANK{2,i}(1,3),'rs','markersize',10),hold on;
plot3(LKNE{2,i}(1,1),LKNE{2,i}(1,2),LKNE{2,i}(1,3),'rs','markersize',10),hold on;

plot3(RFWT{2,i}(1,1),RFWT{2,i}(1,2),RFWT{2,i}(1,3),'rs','markersize',10),hold on;
plot3(LFWT{2,i}(1,1),LFWT{2,i}(1,2),LFWT{2,i}(1,3),'rs','markersize',10),hold on;

plot3(RSHO{2,i}(1,1),RSHO{2,i}(1,2),RSHO{2,i}(1,3),'rs','markersize',10),hold on;
plot3(LSHO{2,i}(1,1),LSHO{2,i}(1,2),LSHO{2,i}(1,3),'rs','markersize',10),hold on;

plot3(RWRA{2,i}(1,1),RWRA{2,i}(1,2),RWRA{2,i}(1,3),'rs','markersize',10),hold on;
plot3(LWRA{2,i}(1,1),LWRA{2,i}(1,2),LWRA{2,i}(1,3),'rs','markersize',10),hold on;

plot3(LELB{2,i}(1,1),LELB{2,i}(1,2),LELB{2,i}(1,3),'rs','markersize',10),hold on;
plot3(RELB{2,i}(1,1),RELB{2,i}(1,2),RELB{2,i}(1,3),'rs','markersize',10),hold on;

plot3(C7{2,i}(1,1),C7{2,i}(1,2),C7{2,i}(1,3),'rs','markersize',10),hold on;
plot3(T10{2,i}(1,1),T10{2,i}(1,2),T10{2,i}(1,3),'rs','markersize',10),hold on;
jointbegin = plot3(RFHD{2,i}(1,1),RFHD{2,i}(1,2),RFHD{2,i}(1,3),'rs','markersize',10);hold on;

%% figure the line between the joint of beginning frame using line cmd

plot3([RANK{2,i}(1,1),RKNE{2,i}(1,1)],[RANK{2,i}(1,2),RKNE{2,i}(1,2)],[RANK{2,i}(1,3),RKNE{2,i}(1,3)],'-rs','LineWidth',2),hold on;
plot3([LANK{2,i}(1,1),LKNE{2,i}(1,1)],[LANK{2,i}(1,2),LKNE{2,i}(1,2)],[LANK{2,i}(1,3),LKNE{2,i}(1,3)],'-rs','LineWidth',2),hold on;

plot3([LKNE{2,i}(1,1),LFWT{2,i}(1,1)],[LKNE{2,i}(1,2),LFWT{2,i}(1,2)],[LKNE{2,i}(1,3),LFWT{2,i}(1,3)],'-rs','LineWidth',2),hold on;
plot3([RKNE{2,i}(1,1),RFWT{2,i}(1,1)],[RKNE{2,i}(1,2),RFWT{2,i}(1,2)],[RKNE{2,i}(1,3),RFWT{2,i}(1,3)],'-rs','LineWidth',2),hold on;

plot3([LFWT{2,i}(1,1),T10{2,i}(1,1)],[LFWT{2,i}(1,2),T10{2,i}(1,2)],[LFWT{2,i}(1,3),T10{2,i}(1,3)],'-rs','LineWidth',2),hold on;
plot3([RFWT{2,i}(1,1),T10{2,i}(1,1)],[RFWT{2,i}(1,2),T10{2,i}(1,2)],[RFWT{2,i}(1,3),T10{2,i}(1,3)],'-rs','LineWidth',2),hold on;
plot3([T10{2,i}(1,1),C7{2,i}(1,1)],[T10{2,i}(1,2),C7{2,i}(1,2)],[T10{2,i}(1,3),C7{2,i}(1,3)],'-rs','LineWidth',2),hold on;
plot3([LFWT{2,i}(1,1),RFWT{2,i}(1,1)],[LFWT{2,i}(1,2),RFWT{2,i}(1,2)],[LFWT{2,i}(1,3),RFWT{2,i}(1,3)],'-rs','LineWidth',2),hold on;

plot3([C7{2,i}(1,1),RSHO{2,i}(1,1)],[C7{2,i}(1,2),RSHO{2,i}(1,2)],[C7{2,i}(1,3),RSHO{2,i}(1,3)],'-rs','LineWidth',2),hold on;
plot3([C7{2,i}(1,1),LSHO{2,i}(1,1)],[C7{2,i}(1,2),LSHO{2,i}(1,2)],[C7{2,i}(1,3),LSHO{2,i}(1,3)],'-rs','LineWidth',2),hold on;
plot3([C7{2,i}(1,1),RFHD{2,i}(1,1)],[C7{2,i}(1,2),RFHD{2,i}(1,2)],[C7{2,i}(1,3),RFHD{2,i}(1,3)],'-rs','LineWidth',2),hold on;

plot3([RSHO{2,i}(1,1),RELB{2,i}(1,1)],[RSHO{2,i}(1,2),RELB{2,i}(1,2)],[RSHO{2,i}(1,3),RELB{2,i}(1,3)],'-rs','LineWidth',2),hold on;
plot3([LSHO{2,i}(1,1),LELB{2,i}(1,1)],[LSHO{2,i}(1,2),LELB{2,i}(1,2)],[LSHO{2,i}(1,3),LELB{2,i}(1,3)],'-rs','LineWidth',2),hold on;

plot3([RELB{2,i}(1,1),RWRA{2,i}(1,1)],[RELB{2,i}(1,2),RWRA{2,i}(1,2)],[RELB{2,i}(1,3),RWRA{2,i}(1,3)],'-rs','LineWidth',2),hold on;
startframe = plot3([LELB{2,i}(1,1),LWRA{2,i}(1,1)],[LELB{2,i}(1,2),LWRA{2,i}(1,2)],[LELB{2,i}(1,3),LWRA{2,i}(1,3)],'-rs','LineWidth',2),hold on;

%% figure the joint of ending frame using BLUE point
plot3(RANK{2,i}(frames,1),RANK{2,i}(frames,2),RANK{2,i}(frames,3),'bs','markersize',10),hold on;
plot3(LANK{2,i}(frames,1),LANK{2,i}(frames,2),LANK{2,i}(frames,3),'bs','markersize',10),hold on;

plot3(RKNE{2,i}(frames,1),RKNE{2,i}(frames,2),RKNE{2,i}(frames,3),'bs','markersize',10),hold on;
plot3(LKNE{2,i}(frames,1),LKNE{2,i}(frames,2),LKNE{2,i}(frames,3),'bs','markersize',10),hold on;

plot3(RFWT{2,i}(frames,1),RFWT{2,i}(frames,2),RFWT{2,i}(frames,3),'bs','markersize',10),hold on;
plot3(LFWT{2,i}(frames,1),LFWT{2,i}(frames,2),LFWT{2,i}(frames,3),'bs','markersize',10),hold on;

plot3(RSHO{2,i}(frames,1),RSHO{2,i}(frames,2),RSHO{2,i}(frames,3),'bs','markersize',10),hold on;
plot3(LSHO{2,i}(frames,1),LSHO{2,i}(frames,2),LSHO{2,i}(frames,3),'bs','markersize',10),hold on;

plot3(RWRA{2,i}(frames,1),RWRA{2,i}(frames,2),RWRA{2,i}(frames,3),'bs','markersize',10),hold on;
plot3(LWRA{2,i}(frames,1),LWRA{2,i}(frames,2),LWRA{2,i}(frames,3),'bs','markersize',10),hold on;
plot3(LELB{2,i}(frames,1),LELB{2,i}(frames,2),LELB{2,i}(frames,3),'bs','markersize',10),hold on;

plot3(RELB{2,i}(frames,1),RELB{2,i}(frames,2),RELB{2,i}(frames,3),'bs','markersize',10),hold on;
plot3(C7{2,i}(frames,1),C7{2,i}(frames,2),C7{2,i}(frames,3),'bs','markersize',10),hold on;
plot3(T10{2,i}(frames,1),T10{2,i}(frames,2),T10{2,i}(frames,3),'bs','markersize',10),hold on;
jointend = plot3(RFHD{2,i}(frames,1),RFHD{2,i}(frames,2),RFHD{2,i}(frames,3),'bs','markersize',10),hold on;

%% figure the line between the joint of ending frame using line cmd

plot3([RANK{2,i}(frames,1),RKNE{2,i}(frames,1)],[RANK{2,i}(frames,2),RKNE{2,i}(frames,2)],[RANK{2,i}(frames,3),RKNE{2,i}(frames,3)],'-bs','LineWidth',2),hold on;
plot3([LANK{2,i}(frames,1),LKNE{2,i}(frames,1)],[LANK{2,i}(frames,2),LKNE{2,i}(frames,2)],[LANK{2,i}(frames,3),LKNE{2,i}(frames,3)],'-bs','LineWidth',2),hold on;

plot3([RKNE{2,i}(frames,1),RFWT{2,i}(frames,1)],[RKNE{2,i}(frames,2),RFWT{2,i}(frames,2)],[RKNE{2,i}(frames,3),RFWT{2,i}(frames,3)],'-bs','LineWidth',2),hold on;
plot3([LKNE{2,i}(frames,1),LFWT{2,i}(frames,1)],[LKNE{2,i}(frames,2),LFWT{2,i}(frames,2)],[LKNE{2,i}(frames,3),LFWT{2,i}(frames,3)],'-bs','LineWidth',2),hold on;


plot3([LFWT{2,i}(frames,1),T10{2,i}(frames,1)],[LFWT{2,i}(frames,2),T10{2,i}(frames,2)],[LFWT{2,i}(frames,3),T10{2,i}(frames,3)],'-bs','LineWidth',2),hold on;
plot3([RFWT{2,i}(frames,1),T10{2,i}(frames,1)],[RFWT{2,i}(frames,2),T10{2,i}(frames,2)],[RFWT{2,i}(frames,3),T10{2,i}(frames,3)],'-bs','LineWidth',2),hold on;
plot3([T10{2,i}(frames,1),C7{2,i}(frames,1)],[T10{2,i}(frames,2),C7{2,i}(frames,2)],[T10{2,i}(frames,3),C7{2,i}(frames,3)],'-bs','LineWidth',2),hold on;
plot3([LFWT{2,i}(frames,1),RFWT{2,i}(frames,1)],[LFWT{2,i}(frames,2),RFWT{2,i}(frames,2)],[LFWT{2,i}(frames,3),RFWT{2,i}(frames,3)],'-bs','LineWidth',2),hold on;

plot3([C7{2,i}(frames,1),RSHO{2,i}(frames,1)],[C7{2,i}(frames,2),RSHO{2,i}(frames,2)],[C7{2,i}(frames,3),RSHO{2,i}(frames,3)],'-bs','LineWidth',2),hold on;
plot3([C7{2,i}(frames,1),LSHO{2,i}(frames,1)],[C7{2,i}(frames,2),LSHO{2,i}(frames,2)],[C7{2,i}(frames,3),LSHO{2,i}(frames,3)],'-bs','LineWidth',2),hold on;
plot3([C7{2,i}(frames,1),RFHD{2,i}(frames,1)],[C7{2,i}(frames,2),RFHD{2,i}(frames,2)],[C7{2,i}(frames,3),RFHD{2,i}(frames,3)],'-bs','LineWidth',2),hold on;

plot3([RSHO{2,i}(frames,1),RELB{2,i}(frames,1)],[RSHO{2,i}(frames,2),RELB{2,i}(frames,2)],[RSHO{2,i}(frames,3),RELB{2,i}(frames,3)],'-bs','LineWidth',2),hold on;
plot3([LSHO{2,i}(frames,1),LELB{2,i}(frames,1)],[LSHO{2,i}(frames,2),LELB{2,i}(frames,2)],[LSHO{2,i}(frames,3),LELB{2,i}(frames,3)],'-bs','LineWidth',2),hold on;

plot3([RELB{2,i}(frames,1),RWRA{2,i}(frames,1)],[RELB{2,i}(frames,2),RWRA{2,i}(frames,2)],[RELB{2,i}(frames,3),RWRA{2,i}(frames,3)],'-bs','LineWidth',2),hold on;
endframe = plot3([LELB{2,i}(frames,1),LWRA{2,i}(frames,1)],[LELB{2,i}(frames,2),LWRA{2,i}(frames,2)],[LELB{2,i}(frames,3),LWRA{2,i}(frames,3)],'-bs','LineWidth',2),hold on;

%% figure the trajectories of joints
plot3(RANK{2,i}(:,1),RANK{2,i}(:,2),RANK{2,i}(:,3),'-k','LineWidth',1),hold on;
plot3(LANK{2,i}(:,1),LANK{2,i}(:,2),LANK{2,i}(:,3),'-k','LineWidth',1),hold on;
plot3(RKNE{2,i}(:,1),RKNE{2,i}(:,2),RKNE{2,i}(:,3),'-k','LineWidth',1),hold on;
plot3(LKNE{2,i}(:,1),LKNE{2,i}(:,2),LKNE{2,i}(:,3),'-k','LineWidth',1),hold on;

root_trajectory = plot3(T10{2,i}(:,1),T10{2,i}(:,2),T10{2,i}(:,3),'-k','LineWidth',4),hold on;
plot3(C7{2,i}(:,1),C7{2,i}(:,2),C7{2,i}(:,3),'-k','LineWidth',1),hold on;

plot3(RSHO{2,i}(:,1),RSHO{2,i}(:,2),RSHO{2,i}(:,3),'-k','LineWidth',1),hold on;
plot3(LSHO{2,i}(:,1),LSHO{2,i}(:,2),LSHO{2,i}(:,3),'-k','LineWidth',1),hold on;

plot3(RFHD{2,i}(:,1),RFHD{2,i}(:,2),RFHD{2,i}(:,3),'-k','LineWidth',1),hold on;

plot3(RELB{2,i}(:,1),RELB{2,i}(:,2),RELB{2,i}(:,3),'-k','LineWidth',1),hold on;
plot3(LELB{2,i}(:,1),LELB{2,i}(:,2),LELB{2,i}(:,3),'-k','LineWidth',1),hold on;
plot3(LWRA{2,i}(:,1),LWRA{2,i}(:,2),LWRA{2,i}(:,3),'-k','LineWidth',1),hold on;grid on;
trajectory = plot3(RWRA{2,i}(:,1),RWRA{2,i}(:,2),RWRA{2,i}(:,3),'-k','LineWidth',1),hold on;
axis image, view(3), legend([startframe endframe root_trajectory trajectory  jointend],...
                            {'Start Frame','End Frame','Root trajectory','Child trajectories','Joint'});

clear all;

