$Version=2$
monthly_gift_list "widget/page"
    {
    title = "Mailings for Gifts Report";
    width=580;
    height=525;
    background="/apps/kardia/images/bg/light_bgnd.jpg";
    widget_template = "/apps/kardia/tpl/kardia-system.tpl", runserver("/apps/kardia/tpl/" + user_name() + ".tpl");

    require_one_endorsement="kardia:gift_manage","kardia:gift_amt";
    endorsement_context=runserver("kardia:ledger:" + :this:ledger + ":");

    ledger "widget/parameter" { type=string; default=null; allowchars="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"; deploy_to_client=yes; }
    period "widget/parameter" { type=string; default=null; deploy_to_client=yes; }
    year_period "widget/parameter" { type=string; default=null; deploy_to_client=yes; }

    rpt_form "widget/form"
	{
	allow_nodata = no;
	allow_new = no;
	auto_focus = no;

	qy_cn "widget/connector" { event=Query; target=f_period; action=SetValue; Value=runclient(:monthly_gift_list:period); }
	qy_cn2 "widget/connector" { event=Query; target=f_show; action=SetValue; Value=runclient('PS'); }

	vb2 "widget/vbox"
	    {
	    x=32;y=8;width=514;height=368;
	    spacing=4;
	    lbl_tb "widget/label" { height=30; font_size=16; text="Mailings for Gifts - Report Options:"; align=center; }
	    pn_sep1 "widget/pane" { height=2; style=lowered; }
	    f_ledger "widget/component" { width=350; height=24; path="/sys/cmp/smart_field.cmp"; field='ledger'; ctl_type=label; text='Ledger:'; value=runserver(:this:ledger); form=rpt_form; label_width=120; }
	    f_period "widget/component"
		{
		width=350;
		height=24;
		path="/sys/cmp/smart_field.cmp";
		field='period';
		ctl_type=dropdown;
		text='Period:';
		label_width=120;
		form=rpt_form;

		sql = runserver("select :a_period + ' - ' + :a_period_desc, :a_period, (:a_period == " + quote(:this:period) + ") from /apps/kardia/data/Kardia_DB/a_period/rows where :a_ledger_number = " + quote(:this:ledger) + " and :a_summary_only = 0 order by :a_parent_period desc, :a_period asc");
		}
	    f_show "widget/component" { path="/sys/cmp/smart_field.cmp"; field=show; height=24; width=350; ctl_type=dropdown; text="Show:"; label_width=120; form=rpt_form; sql = "select label='Selections and Publications', value='PS', def=1; select label='Selections', value='S', def=0; select label='Publications', value='P', def=0"; }
	    sep "widget/autolayoutspacer" { height=4; }
	    //f_unposted "widget/component" { x=10; width=400; height=24; path="/sys/cmp/smart_field.cmp"; field="unposted"; ctl_type='checkboxleft'; text="Include unposted transactions"; form=rpt_form; label_width=120; }
	    f_level "widget/component" { width=350; height=24; path="/sys/cmp/smart_field.cmp"; field='report_level'; ctl_type=dropdown; text='Detail Level:'; sql=runserver("select '' + :a_reporting_level + ' - ' + :a_level_rpt_desc, :a_reporting_level from /apps/kardia/data/Kardia_DB/a_reporting_level/rows where :a_ledger_number = " + quote(:this:ledger)); form=rpt_form; label_width=120; }
	    f_docfmt "widget/component"
		{ 
		width=350; height=24; 
		path="/sys/cmp/smart_field.cmp"; 
		field='document_format'; 
		ctl_type=dropdown; 
		text='Format:'; 
		sql = runserver("select :t:type_description + ' (' + :t:type_name + ')', :t:type_name from /sys/cx.sysinfo/osml/types t, /sys/cx.sysinfo/prtmgmt/output_types ot where :t:type_name = :ot:type order by :t:type_description");
		form=rpt_form;
		label_width=120;
		}
	    }

	vb3 "widget/vbox"
	    {
	    x=32;y=384;width=514;height=140;
	    align=bottom;

	    spacing=4;

	    note "widget/label" { height=40; style=italic; text="This report can take a while to run.  You should only run this report when no one is entering gifts in Receipting."; }

	    pn_sep2 "widget/pane" { height=2; style=lowered; }

	    ctls_hbox "widget/hbox"
		{
		height=32;
		spacing=4;
		rpt_print "widget/textbutton"
		    {
		    width=90;
		    text="Print";
		    //enabled = runclient(char_length(:f_year:content) > 0);
		    rpt_print_cn "widget/connector" { event="Click"; target="rpt_form"; action="Submit"; Target=runclient("monthly_gift_list"); NewPage=runclient(1); Source=runclient("/apps/kardia/modules/rcpt/monthly_gift_list.rpt"); Width=runclient(800); Height=runclient(600); }
		    }
		rpt_cancel "widget/textbutton"
		    {
		    width=90;
		    text="Cancel";
		    rpt_cancel_cn "widget/connector" { event="Click"; target="monthly_gift_list"; action="Close"; }
		    }
		}
	    }
	}
    }
