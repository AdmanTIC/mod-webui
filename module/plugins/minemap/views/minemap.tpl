%# If got no group, bailout
%if not group:
%rebase("layout", title='Invalid group name')

Invalid group name

%else:

%if group=='all':
%groupname = 'all'
%groupalias = 'All hosts'
%title = 'Minemap for all hosts and services'
%else:
%groupname = group.get_name()
%groupalias = group.alias
%title = "Minemap for: <a href='/hosts-group/%s'>%s</a>" % (groupname, groupalias)
%end

%helper = app.helper
%datamgr = app.datamgr

%#rows and columns will contain, respectively, all different hosts and all different services ...
%rows = []
%columns = []

%nHosts=0
%hUp=0
%hDown=0
%hUnreachable=0
%hPending=0
%hUnknown=0
%for h in hosts:
   %if not h.get_name() in rows:
      %# Include host name even if it has no services ...
      %rows.append(h.get_name())
      
      %nServices=0
      %for s in h.services:
         %nServices=nServices+1
         %if not s.get_name() in columns:
            %columns.append(s.get_name())
         %end
      %end

      %nHosts=nHosts+1
      %if h.state == 'UP':
         %hUp=hUp+1
      %elif h.state == 'DOWN':
         %hDown=hDown+1
      %elif h.state == 'UNREACHABLE':
         %hUnreachable=hUnreachable+1
      %elif h.state == 'PENDING':
         %hPending=hPending+1
      %else:
         %hUnknown=hUnknown+1
      %end
   %end
%end
%if nHosts > 0:
   %pctUp            = round(100.0 * hUp / nHosts, 2)
   %pctDown          = round(100.0 * hDown / nHosts, 2)
   %pctUnreachable   = round(100.0 * hUnreachable / nHosts, 2)
   %pctPending       = round(100.0 * hPending / nHosts, 2)
   %pctUnknown       = round(100.0 * hUnknown / nHosts, 2)
%else:
   %pctUp            = 0
   %pctDown          = 0
   %pctUnreachable   = 0
   %pctPending       = 0
   %pctUnknown       = 0
%end

%rows.sort()
%columns.sort()
%end

%# Specific content for breadrumb
%rebase("layout", title='Minemap for ' + groupalias, refresh=True, css=['minemap/css/minemap.css'], breadcrumb=[ ['All hosts', '/minemaps'], [groupalias, '/hosts-group/'+groupname] ])


<div id="content_container">
   <div class="panel panel-default">
      <div class="panel-heading">
         <h3 class="panel-title">{{groupname}} / ({{groupalias}})</h3>
      </div>
      <div class="panel-body">
         <div class="pull-left col-lg-2" style="height: 45px;">
            <span>Members:</span>
            <span>{{nHosts}} hosts</span>
         </div>
         <div class="pull-right progress col-lg-6 no-bottommargin no-leftpadding no-rightpadding" style="height: 45px;">
            <div title="{{hUp}} hosts Up" class="progress-bar progress-bar-success quickinfo" role="progressbar" 
               data-original-title='{{hUp}} Up' 
               style="width: {{pctUp}}%; vertical-align:midddle; line-height: 45px;">{{pctUp}}% Up</div>
            <div title="{{hDown}} hosts Down" class="progress-bar progress-bar-danger quickinfo" 
               data-original-title='{{hDown}}% Unreachable' 
               style="width: {{pctDown}}%; vertical-align:midddle; line-height: 45px;">{{pctDown}}% Down</div>
            <div title="{{hUnreachable}} hosts Unreachable" class="progress-bar progress-bar-warning quickinfo" 
               data-original-title='{{hUnreachable}} Down' 
               style="width: {{pctUnreachable}}%; vertical-align:midddle; line-height: 45px;">{{pctUnreachable}}% Unreachable</div>
            <div title="{{hPending}} hosts Pending/Unknown" class="progress-bar progress-bar-info quickinfo" 
               data-original-title='{{hPending + hUnknown}} Pending / Unknown' 
               style="width: {{pctPending}}%; vertical-align:midddle; line-height: 45px;">{{pctPending + pctUnknown}}% Pending or Unknown</div>
         </div>
      </div>
   </div>

   <div>
      <div class='col-lg-12'>
         &nbsp;
         %include("pagination_element", navi=navi, app=app, page="minemap/"+groupname, div_class="center no-margin")
      </div>
   </div>

   <div>
      <div class="clearfix">
         <table class="table table-hover minemap">
            <thead>
               <tr>
                  <th></th>
                  %for c in columns:
                     <th class="vertical">
                     <div class="rotated-text"><span class="rotated-text__inner">{{c}}</span></div>
                     </th>
                  %end
               </tr>
            </thead>
            <tbody>
               %for r in rows:
                  %h = app.get_host(r)
                  %if h:
                  <tr>
                     <td>
                        <span title="{{h.state}} - {{helper.print_duration(h.last_chk)}} - {{h.output}}">
                        {{!helper.get_fa_icon_state(h)}}
                        </span>
                        <a href="/host/{{h.get_name()}}">
                           {{h.get_name()}}
                        </a>
                     </td>
                     %for c in columns:
                        %s = app.get_service(r, c)
                        %if s:
                           %if s.get_name() in params['minemap_servicesHide']:
                           <td>&nbsp;</td>
                           %continue
                           %end
                           %if s.business_impact in params['minemap_servicesLevel']:
                           <td>
                              <a href="/service/{{h.get_name()}}/{{s.get_name()}}">
                                 <span title="{{s.state}} - {{helper.print_duration(s.last_chk)}} - {{s.output}}">
                                 {{!helper.get_fa_icon_state(s)}}
                                 </span>
                              </a>
                           </td>
                           %else:
                              <td>&nbsp;</td>
                           %end
                        %else:
                           <td>&nbsp;</td>
                        %end
                     %end
                  %end
                  </tr>
               %end
            </tbody>
         </table>
      </div>
   </div>

   <div>
      <div class='col-lg-12'>
         &nbsp;
         %include("pagination_element", navi=navi, app=app, page="minemap/"+groupname, div_class="center no-margin")
      </div>
   </div>
</div>
