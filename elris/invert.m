function invert(varargin)
        %val = get(handles.FileListBox, 'value');        
        %nodir=handles.DataID(1)-1;
        %data=handles.DataContents{val-nodir};
        
        fname = 'a5_1_ws_6.dat';
        data = getResisitivityData(fname);

        %set(handles.InvBut,'Enable','off')
        %cocuk=get(handles.resip,'Children');
        %secili=get(handles.resip,'SelectedObject');
        %kont=get(secili,'String');
        %if strcmp(kont,'IP')
        %    kont2=find(cocuk~=secili);
        %    set(handles.resip,'SelectedObject',cocuk(2))
        %end
        
        % Getting inversion settings
        %itmax = (get(handles.numiter,'Value'));
        itmax = 5;
        
        if itmax==11
            itmax=15;
        end
%         for k=1:4
%             opt(k) = get(handles.(['gosterim',num2str(k)]),'Value');
%         end
%         mtype=get(handles.mesh,'value');
        
        mtype = 1
        switch mtype
            case 0
                xa=1; za=1;
            case 1
                xa=2; za=1; % divides each cell into half
        end
        if ~isempty(data)
            alfax=1;
            alfaz=1;
            yky=1/data.zmax;%
            %             yky=1/((data.nel-1)*data.ela);
            %             yky=1/data.zmax;
            lambda=std(log(data.roa));
            % Mesh generator
            switch mtype
                case 0 %Fine mode selected
                    [p,t,nlay,tev,par,npar,z,xel,nx,nz]=meshgena(data);
                    parc=1:npar;
                    parc=reshape(parc,nlay,2*(data.nel-1));
                    parc=[parc;zeros(1,size(parc,2))];
                    parc=[zeros(size(parc,1),1),parc,zeros(size(parc,1),1)];
                    C=full(delsq(parc));
                    say=1;
                    for k=1:nx
                        for m=1:nz
                            yx1=(k-1)*xa+1;yx2=(k-1)*xa+xa+1;
                            yy1=(m-1)*za+1;yy2=(m-1)*za+za+1;
                            xp(say,:)=[xel(yx1) xel(yx2) xel(yx2) xel(yx1)];
                            zp(say,:)=[z(yy1) z(yy1) z(yy2) z(yy2)];
                            say=say+1;
                        end
                    end
                case 1 % Normal mode selected
                    [p,t,nlay,tev,par,npar,z]=meshgen(data);
                    
                    parc=1:npar;
                    say=1;
                    for k=1:data.nel-1
                        for m=1:length(z)-1
                            xp(say,:)=[data.xelek(k) data.xelek(k+1) data.xelek(k+1) data.xelek(k)];
                            zp(say,:)=[z(m) z(m) z(m+1) z(m+1)];
                            say=say+1;
                        end
                        
                    end
                    parc=reshape(parc,nlay,data.nel-1);
                    parc=[parc;zeros(1,size(parc,2))];
                    parc=[zeros(size(parc,1),1),parc,zeros(size(parc,1),1)];
                    C=full(delsq(parc));
            end
            [sig,es,ds,akel,V1,k1,prho,so,indx,pma,nu]=initial(t,p,data,yky,npar) ;
            
            sd=1./data.roa.^.025;
            %
            Rd=diag(sd);
%             clear_main_panel(handles)
            
%             g3 = get(handles.gosterim1,'Value');
%             set(handles.progressbar, 'position', [.8 0 0.01 1]);
%             set(handles.progressbar ,'Visible','on')
            %
            tic
            
            for iter=1:itmax
                % Forward operator
                
                [J,ro]=forward(yky,t,es,sig,so,data.nel,akel,1,tev,k1,indx,V1,data,prho,npar,par,p);
                dd=log(data.roa(:))-log(ro(:));
                misfit=sqrt((Rd*dd)'*(Rd*dd)/data.nd)*100;
                % Parameter update
                
                [misfit,sig,prho,ro]=pupd(data,J,par,yky,t,es,akel,tev,k1,indx,V1,prho',npar,dd,so,p,C,lambda,Rd);
%                 figure
%                 pdeplot(p,[],t,'xydata',1./sig,'xystyle','flat')
                
                mfit(iter)=misfit;
                g3 =1;
                switch g3
                    case 0
                        cizro=prho';
                    case 1
                        cizro=log10(prho');
                end
                % Graph the results of iterations
                
                if iter==1
                    alp=sum(abs(J),1);
                    alp=alp/max(alp);
                    alp1=repmat(alp,4,1);
                    alp1=(alp1(:));
                    alp1=alp1+(.91-min(alp1));
                    alp1(alp1>1)=1;
                    %mod_graph(xp,zp,cizro,alp1,data.xelek,iter,misfit,data.nel,handles.ModRes)
                    %pseudo(data.xd,data.psd,ro,handles.CalcResPsd,2,opt,data.xelek,data.zelek,[],2);
                    %pseudo(data.xd,data.psd,data.roa,handles.MeasResPsd,1,opt,data.xelek,data.zelek,[],2);
                    %imagemenu_tr_contour(handles);
                    %set(handles.MeasResPsd,'XLim',[data.xelek(1) data.xelek(end)])
                    %set(handles.CalcResPsd,'XLim',[data.xelek(1) data.xelek(end)])
                    %resizeFcn;
                    %c=caxis(handles.MeasResPsd);
                    %caxis(handles.CalcResPsd,c)
                    %drawnow;
                else
                    %hh=handles.model;
                    %set(hh,'CData',repmat(cizro,4,1))
                    %title(handles.ModRes,['Model Resistivity Section',' Iteration : ', num2str(iter),' RMS % = ',sprintf('%5.2f',misfit)]);
                    %axpos=get(handles.ModRes,'position');
                    %pseudo(data.xd,data.psd,ro,handles.CalcResPsd,2,opt,data.xelek,data.zelek,[],2);
                    %set(handles.CalcResPsd,'XLim',[data.xelek(1) data.xelek(end)])
                    %c=caxis(handles.MeasResPsd);
                    %caxis(handles.CalcResPsd,c)
                    %drawnow;
                end
                oran=.2*(1/itmax)*iter;
%                 set(handles.progressbar, 'position', [.8 0 oran 1]);%,'BackGroundColor',[255-oran*255 255 255-oran*255]/255);
%                 
%                 set(handles.statusText, 'string', ...
%                     sprintf('Iteration ... %d / %d',iter,itmax))
%                 drawnow;
                %Stop the inversion if the improvement in the misfit is
                %less than %2.5
                if iter>1
                    farkm=abs(mfit(iter)-mfit(iter-1))./mfit(iter);
                    if farkm<.025
                        break
                    end
                end
                if iter>=2
                    lambda=lambda*.55;
                end
            end
            if data.ip
                [pma,misfit_ip,mac,iterx]=pure_ip(data,ro,sig,J,prho,C,es,akel,V1,k1,so,indx,pma,nu,tev,par,p,t,npar,Rd);
            end
            
            
%             itime=toc;
%             yer=get(handles.statusText,'position');
%             set(handles.statusText, 'string', ...
%                 [num2str(iter), ' iterations completed in ',sprintf('%5.2f',itime),' seconds.'],'position', [.78, .0, .2 .81]);
%             %Enable context menus
%             imagemenu_tr_patch(handles);
%             imagemenu_tr_contour(handles);
%             set(handles.progressbar ,'Visible','off')
%             pause(1)
%             set(handles.statusText, 'string', '','position',yer)
            % Save inversion results for future display
            dadi= fname; %handles.DataNames{val-nodir};
            dadi(end-2:end)='mat';
            if data.ip==0
                save ([pwd,'/',dadi],'data','xp','zp','prho','misfit','iter','ro','alp1','-mat')
%                set(handles.InvBut,'Enable','on')
            else
                save ([pwd,'/',dadi],'data','xp','zp','prho','misfit','iter','ro','alp1','pma','mac','misfit_ip','-mat')
%                set(handles.InvBut,'Enable','on')
                
            end
            
        end
end
    
%--------------------------------------------------------------------------
% getResisitivityData
%   This reads in all supported data files in the current directory
%--------------------------------------------------------------------------
    function record = getResisitivityData(filename)
        [record]=read_data(filename);
    end

