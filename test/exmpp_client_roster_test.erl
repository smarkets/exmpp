-module(exmpp_client_roster_test).

-include_lib("eunit/include/eunit.hrl").

-include("exmpp.hrl").

get_roster_test() ->
	R = exmpp_client_roster:get_roster(),
	?assertEqual(<<"get">>, exxml:get_attribute(R, <<"type">>, undefined)),
	?assertEqual(?NS_ROSTER, exxml:get_path(R, [{element, <<"query">>}, {attribute, <<"xmlns">>}])),
	ok.


set_item_test() ->
	R = exmpp_client_roster:set_item(<<"user@domain.com">>, [<<"g1">>, <<"g2">>], <<"nick">>),
	?assertEqual(<<"set">>, exxml:get_attribute(R, <<"type">>, undefined)),
	?assertEqual(?NS_ROSTER, exxml:get_path(R, [{element, <<"query">>}, {attribute, <<"xmlns">>}])),
	?assertEqual(<<"user@domain.com">>, 
		exxml:get_path(R, [{element, <<"query">>}, {element, <<"item">>}, {attribute, <<"jid">>}])),
	?assertEqual(<<"nick">>, 
		exxml:get_path(R, [{element, <<"query">>}, {element, <<"item">>}, {attribute, <<"name">>}])),
	?assertMatch({xmlel, _, _, 
			[{xmlel, <<"group">>, _, [{cdata, <<"g1">>}]}, 
			 {xmlel, <<"group">>, _, [{cdata, <<"g2">>}]}]}, 
		exxml:get_path(R, [{element, <<"query">>}, {element, <<"item">>}])),
	ok.
