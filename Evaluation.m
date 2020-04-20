load Data/wsare_results.mat;
load Result/eigenevent.mat;
%load Result/Exp/pvalue-eigenvector-selection/08.mat
load Data/rel.mat;

nowclock=clock;
logfile=sprintf('Log/Evaluation-%d-%d-%d-%d-%d-%d.log',nowclock(1),nowclock(2),nowclock(3),nowclock(4),nowclock(5),round(nowclock(6)));
matfile=sprintf('Log/Evaluation-%d-%d-%d-%d-%d-%d.mat',nowclock(1),nowclock(2),nowclock(3),nowclock(4),nowclock(5),round(nowclock(6)));

fid=fopen(logfile,'w');

for n=1:231
pval=((n-1))/1000+20/1000;

for dataset=1:100
    k{dataset}(1)=0;
    k{dataset}(2)=0;
    k{dataset}(3)=0;
    k{dataset}(4)=0;
    for i=1:365
        if wsare2{dataset}(i)<=pval
            k{dataset}(1)=k{dataset}(1)+1;
            Events{1}{dataset}(k{dataset}(1))=i;
        end    
        if wsare25{dataset}(i)<=pval
            k{dataset}(2)=k{dataset}(2)+1;
            Events{2}{dataset}(k{dataset}(2))=i;
        end
        if wsare3{dataset}(i)<=pval
            k{dataset}(3)=k{dataset}(3)+1;
            Events{3}{dataset}(k{dataset}(3))=i;
        end   
        if eigenevent{dataset}(i)<=pval
            k{dataset}(4)=k{dataset}(4)+1;
            Events{4}{dataset}(k{dataset}(4))=i;
        end   
    end    
end    

for t=1:4
    for dataset=1:100
        if k{dataset}(t)==0
            False=0;
            True=0;
            Alarms=0;
            DetectedDay=14;
        else
            reldate=rel(dataset)-74144+1;
            Alarms=size(Events{t}{1,dataset},2);
            False=size(find(Events{t}{1,dataset}<reldate),2);
            True=Alarms-False;
            if find(Events{t}{1,dataset}>reldate)
                DetectedDay=Events{t}{1,dataset}(min(find(Events{t}{1,dataset}>reldate)))-reldate;
                if DetectedDay>14 
                    DetectedDay=14;
                end     
            else
                DetectedDay=14;
            end
            
        end
        
        WResult{t}(1,dataset)=False;
        WResult{t}(2,dataset)=DetectedDay;
        
        FR{t}(n,dataset)=False;
        DL{t}(n,dataset)=DetectedDay;
        

    end
    disp(sprintf ('n=%d, Method %d, Pvalue=%f, Delay= %f,False/Month=%f',n,t,pval,mean(WResult{t}(1,:))/12,mean(WResult{t}(2,:)) ));
	fprintf (fid,'n=%d, Method %d, Pvalue=%f, Delay= %f,False/Month=%f\n',n,t,pval,mean(WResult{t}(1,:))/12,mean(WResult{t}(2,:)) );
    X{t}(n)=mean(WResult{t}(1,:))/12;
    Y{t}(n)=mean(WResult{t}(2,:));
end

end
%clearex('X','Y','wsare2','wsare25','wsare3','eigenevent');

save('Result/FP-Delay.mat', 'X','Y')

f2=figure;
%plot(X{3},Y{3},'b'); hold on;
%plot(X{2},Y{2},'r'); hold on;
%plot(X{1},Y{1},'g');  hold on;
%plot(X{4},Y{4},'k');
plot(X{3},Y{3},'--k','LineWidth',1); hold on;
plot(X{2},Y{2},':k','LineWidth',1); hold on;
plot(X{1},Y{1},'-.k','LineWidth',1 );  hold on;
plot(X{4},Y{4},'-k','LineWidth',2);
title('AMOC Curve');
legend({'WSARE 3.0', 'WSARE 2.5', 'WSARE 2.0','EigenEvent'});
xlabel('False Posetive per month');
ylabel('Detection Time in days');
%saveas(f2, 'ExpFigures/Fig2/exp01.png','png');

Points(1,:)=X{1};
Points(2,:)=Y{1};
Points(3,:)=X{2};
Points(4,:)=Y{2};
Points(5,:)=X{3};
Points(6,:)=Y{3};
Points(7,:)=X{4};
Points(8,:)=Y{4};

f3=figure;
plot(Points(8,:),'k'); hold on;
plot(Points(6,:),'b'); hold on;
plot(Points(4,:),'r'); hold on;
plot(Points(2,:),'g');
title('Detection Power')
xlabel('P-value');
ylabel('Detection Time in days');
%saveas(f3, 'ExpFigures/Fig3/exp01.png','png');

f4= figure;
plot(Points(7,:),'k'); hold on;
plot(Points(5,:),'b'); hold on;
plot(Points(3,:),'r'); hold on;
plot(Points(1,:),'g'); 
title('Trustability Power')
xlabel('P-value');
ylabel('False Posetive per month');
%saveas(f4, 'ExpFigures/Fig4/exp01.png','png');

AUAMOC1=trapz (X{1},Y{1});
AUAMOC2=trapz (X{2},Y{2});
AUAMOC3=trapz (X{3},Y{3});
AUAMOC4=trapz (X{4},Y{4});


disp(sprintf('WSARE2, False Average =%f, Delay=%f, AUAMOC=%f',mean(X{1}),mean(Y{1}),AUAMOC1));
disp(sprintf('WSARE2.5, False Average =%f, Delay=%f, AUAMOC=%f',mean(X{2}),mean(Y{2}),AUAMOC2));
disp(sprintf('WSARE3.0, False Average =%f, Delay=%f, AUAMOC=%f',mean(X{3}),mean(Y{3}),AUAMOC3));
disp(sprintf('EigenEvent, False Average =%f, Delay=%f, AUAMOC=%f',mean(X{4}),mean(Y{4}),AUAMOC4));

disp(sprintf('WSARE2, Best False Average =%f, Delay=%f',min(X{1}),min(Y{1})));
disp(sprintf('WSARE2.5, Best False Average =%f, Delay=%f',min(X{2}),min(Y{2})));
disp(sprintf('WSARE3.0, Best False Average =%f, Delay=%f',min(X{3}),min(Y{3})));
disp(sprintf('EigenEvent, Best False Average =%f, Delay=%f',min(X{4}),min(Y{4})));

disp(sprintf('WSARE2, Worst False Average =%f, Delay=%f',max(X{1}),max(Y{1})));
disp(sprintf('WSARE2.5, Worst False Average =%f, Delay=%f',max(X{2}),max(Y{2})));
disp(sprintf('WSARE3.0, Worst False Average =%f, Delay=%f',max(X{3}),max(Y{3})));
disp(sprintf('EigenEvent, Worst False Average =%f, Delay=%f',max(X{4}),max(Y{4})));

n=51;
disp(sprintf('Pvalue =0.05, WSARE2,  False Average =%f, Delay=%f',X{1}(n),Y{1}(n)));
disp(sprintf('Pvalue =0.05, WSARE2.5,  False Average =%f, Delay=%f',X{2}(n),Y{2}(n)));
disp(sprintf('Pvalue =0.05, WSARE3,  False Average =%f, Delay=%f',X{3}(n),Y{3}(n)));
disp(sprintf('Pvalue =0.05, EigenEvent,  False Average =%f, Delay=%f',X{4}(n),Y{4}(n)));
% ********************

fprintf(fid,'\n\nWSARE2, FalseAverage =%f, Delay=%f, AUAMOC=%f\n',mean(X{1}),mean(Y{1}),AUAMOC1);
fprintf(fid,'WSARE2.5, FalseAverage =%f, Delay=%f, AUAMOC=%f\n',mean(X{2}),mean(Y{2}),AUAMOC2);
fprintf(fid,'WSARE3.0, FalseAverage =%f, Delay=%f, AUAMOC=%f\n',mean(X{3}),mean(Y{3}),AUAMOC3);
fprintf(fid,'EigenEvent, FalseAverage =%f, Delay=%f, AUAMOC=%f\n\n',mean(X{4}),mean(Y{4}),AUAMOC4);
fprintf(fid,'WSARE2, BestFalse=%f, Delay=%f\n',min(X{1}),min(Y{1}));
fprintf(fid,'WSARE2.5, BestFalse=%f, Delay=%f\n',min(X{2}),min(Y{2}));
fprintf(fid,'WSARE3.0, BestFalse=%f, Delay=%f\n',min(X{3}),min(Y{3}));
fprintf(fid,'EigenEvent, BestFalse=%f, Delay=%f\n\n',min(X{4}),min(Y{4}));
fprintf(fid,'WSARE2, WorstFalse=%f, Delay=%f\n',max(X{1}),max(Y{1}));
fprintf(fid,'WSARE2.5, WorstFalse=%f, Delay=%f\n',max(X{2}),max(Y{2}));
fprintf(fid,'WSARE3.0, WorstFalse=%f, Delay=%f\n',max(X{3}),max(Y{3}));
fprintf(fid,'EigenEvent, WorstFalse=%f, Delay=%f\n',max(X{4}),max(Y{4}));

save('Data/FinalResults.mat', 'X','Y','Points');
fclose(fid);

save (matfile);