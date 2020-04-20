addpath(genpath('tensor_toolbox_2.5'));
addpath(genpath('tensorCode'));

nowclock=clock;
logfile=sprintf('Log/EigenEvent-%d-%d-%d-%d-%d-%d.log',nowclock(1),nowclock(2),nowclock(3),nowclock(4),nowclock(5),round(nowclock(6)));
matfile=sprintf('Log/EigenEvent-%d-%d-%d-%d-%d-%d.mat',nowclock(1),nowclock(2),nowclock(3),nowclock(4),nowclock(5),round(nowclock(6)));
fid=fopen(logfile,'w');
for ds=0:99
	dataset=ds+1;
    nsdistance{dataset}(1)=0;
    nsdistance2{dataset}(1)=0;
	load (sprintf('Data/data%d.mat',ds));
    tns2{dataset}(:,:,1)=zeros(size(day{dataset}{1,1}));;
	dd=0;
    for dayid=1:730
        testc=day{dataset}{1,dayid};
        today_env_setting=dayat{dataset}(dayid,:);
        k=0;
        
        for i=1:dayid-1
            if dayat{dataset}(i,:) == today_env_setting
                k=k+1;
                tns2{dataset}(:,:,k)=day{1,dataset}{1,i};
            end    
        end    
        
        testp=tensor(tns2{dataset});
        testc=tensor(testc);
        %[spatial features temporal]
        dimension = [1,1,1];
        [TPtest,CPtest] = DTA(testp,dimension);
        [TCtest,CCtest] = DTA(testc,dimension);
            
        ccore=TCtest.core(1,1);
        if size(size(TPtest.core),2)==3
            pcore=TPtest.core(:,:,1).data(1,1);
        else
            pcore=TPtest.core(1,1);
        end
            
        a1=TCtest.U{1}(:,1);
        b1=TPtest.U{1}(:,1);
         
        sdist=norm(a1-b1);
        sdist2=abs(ccore/pcore);
                
        if dayid>365
                sdistance{dataset}(dayid-365)=sdist;
                sdistance2{dataset}(dayid-365)=sdist2;
                u1=mean(nsdistance{dataset});
                sigma1=std(nsdistance{dataset});
                u2=mean(nsdistance2{dataset});
                sigma2=std(nsdistance2{dataset});
                pvalue1=(1-erf(((sdist-u1)/sigma1)/sqrt(2)))/2;
                pvalue2=(1-erf(((sdist2-u2)/sigma2)/sqrt(2)))/2;
                pvalue=min([pvalue1; pvalue2]);
                eigenevent{dataset}(dayid-365)=pvalue ;
        end


		if k>0
			dd=dd+1;
			nsdistance{dataset}(dd)=sdist;
			nsdistance2{dataset}(dd)=sdist2;
        end
  
       
        rr=dd;
        if rr==0
            rr=1;
        end    
        
        nowclock=clock;
        nowtime=sprintf('%d:%d:%d',nowclock(4),nowclock(5),round(nowclock(6)));
        disp(sprintf('%s : dataset=%d, t=%d, e=%d%d%d%d, k=%d, d1=%f, d2=%f, size(d1)=%d, size(B)=[%d]',nowtime,dataset,dayid,k,today_env_setting,sdist,sdist2,size(nsdistance{dataset},2),size(tns2{dataset},3)));
        fprintf(fid,'%s : dataset=%d, t=%d, e=%d%d%d%d, k=%d, d1=%f, d2=%f, size(d1)=%d, size(B)=[%d]\n',nowtime,dataset,dayid,k,today_env_setting,sdist,sdist2,size(nsdistance{dataset},2),size(tns2{dataset},3));

	end
end
fclose(fid);
save('Result/eigenevent.mat','eigenevent');
save (matfile);