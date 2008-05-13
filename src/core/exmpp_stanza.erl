% $Id$

%% @author Mickael Remond <mickael.remond@process-one.net>
%% @author Jean-Sébastien Pédron <js.pedron@meetic-corp.com>
%% @copyright Process-One [http://www.process-one.net/]

%% @doc
%% The module <strong>{@module}</strong> provides helper to manipulate
%% standard stanza.

-module(exmpp_stanza).
-vsn('$Revision$').

-include("exmpp.hrl").

% Stanza common components.
-export([
  get_error/1
]).

% Stanza standard attributes.
-export([
  get_sender/1,
  get_sender_from_attrs/1,
  set_sender/2,
  set_sender_in_attrs/2,
  get_recipient/1,
  get_recipient_from_attrs/1,
  set_recipient/2,
  set_recipient_in_attrs/2,
  get_id/1,
  get_id_from_attrs/1,
  set_id/2,
  set_id_in_attrs/2,
  get_type/1,
  get_type_from_attrs/1,
  set_type/2,
  set_type_in_attrs/2,
  get_lang/1,
  get_lang_from_attrs/1,
  set_lang/2,
  set_lang_in_attrs/2
]).

% Common operations.
-export([
  reply/1,
  reply_from_attrs/1,
  reply_with_error/2
]).

% Stanza-level errors.
-export([
  error/2,
  error/3,
  stanza_error/2,
  stanza_error_without_original/2,
  is_stanza_error/1,
  get_error_type/1,
  set_error_type/2,
  set_error_type_from_condition/2,
  get_condition/1,
  get_text/1
]).

% --------------------------------------------------------------------
% Stanza common components.
% --------------------------------------------------------------------

%% @spec (Stanza) -> Error | undefined
%%     Stanza = exmpp_xml:xmlnselement()
%%     Error = exmpp_xml:xmlnselement()
%% @doc Return the error element from `Stanza'.
%%
%% The error element is supposed to have the name `error' and the same
%% namespace as the stanza.

get_error(#xmlnselement{ns = NS} = Stanza) ->
    exmpp_xml:get_element_by_name(Stanza, NS, 'error').

% --------------------------------------------------------------------
% Stanza standard attributes.
% --------------------------------------------------------------------

%% @spec (Stanza) -> Sender | nil()
%%     Stanza = exmpp_xml:xmlnselement()
%%     Sender = string()
%% @doc Return the sender.
%%
%% The return value should be a JID and may be parsed with
%% {@link exmpp_jid:string_to_jid/1}.

get_sender(#xmlnselement{attrs = Attrs} = _Stanza) ->
    get_sender_from_attrs(Attrs).

%% @spec (Attrs) -> Sender | nil()
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     Sender = string()
%% @doc Return the sender.
%%
%% The return value should be a JID and may be parsed with
%% {@link exmpp_jid:string_to_jid/1}.

get_sender_from_attrs(Attrs) ->
    exmpp_xml:get_attribute_from_list(Attrs, 'from').

%% @spec (Stanza, Sender) -> New_Stanza
%%     Stanza = exmpp_xml:xmlnselement()
%%     Sender = string()
%%     New_Stanza = exmpp_xml:xmlnselement()
%% @doc Set the sender.

set_sender(#xmlnselement{attrs = Attrs} = Stanza, Sender) ->
    New_Attrs = set_sender_in_attrs(Attrs, Sender),
    Stanza#xmlnselement{attrs = New_Attrs}.

%% @spec (Attrs, Sender) -> New_Attrs
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     Sender = string()
%%     New_Attrs = [exmpp_xml:xmlnsattribute()]
%% @doc Set the sender.

set_sender_in_attrs(Attrs, Sender) ->
    exmpp_xml:set_attribute_in_list(Attrs, 'from', Sender).

%% @spec (Stanza) -> Recipient | nil()
%%     Stanza = exmpp_xml:xmlnselement()
%%     Recipient = string()
%% @doc Return the recipient.
%%
%% The return value should be a JID and may be parsed with
%% {@link exmpp_jid:string_to_jid/1}.

get_recipient(#xmlnselement{attrs = Attrs} = _Stanza) ->
    get_recipient_from_attrs(Attrs).

%% @spec (Attrs) -> Recipient | nil()
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     Recipient = string()
%% @doc Return the recipient.
%%
%% The return value should be a JID and may be parsed with
%% {@link exmpp_jid:string_to_jid/1}.

get_recipient_from_attrs(Attrs) ->
    exmpp_xml:get_attribute_from_list(Attrs, 'to').

%% @spec (Stanza, Recipient) -> New_Stanza
%%     Stanza = exmpp_xml:xmlnselement()
%%     Recipient = string()
%%     New_Stanza = exmpp_xml:xmlnselement()
%% @doc Set the recipient.

set_recipient(#xmlnselement{attrs = Attrs} = Stanza, Recipient) ->
    New_Attrs = set_recipient_in_attrs(Attrs, Recipient),
    Stanza#xmlnselement{attrs = New_Attrs}.

%% @spec (Attrs, Recipient) -> New_Attrs
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     Recipient = string()
%%     New_Attrs = [exmpp_xml:xmlnattribute()]
%% @doc Set the recipient.

set_recipient_in_attrs(Attrs, Recipient) ->
    exmpp_xml:set_attribute_in_list(Attrs, 'to', Recipient).

%% @spec (Stanza) -> ID | nil()
%%     Stanza = exmpp_xml:xmlnselement()
%%     ID = string()
%% @doc Return the stanza ID.

get_id(#xmlnselement{attrs = Attrs} = _Stanza) ->
    get_id_from_attrs(Attrs).

%% @spec (Attrs) -> ID | nil()
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     ID = string()
%% @doc Return the stanza ID.

get_id_from_attrs(Attrs) ->
    exmpp_xml:get_attribute_from_list(Attrs, 'id').

%% @spec (Stanza, ID) -> New_Stanza
%%     Stanza = exmpp_xml:xmlnselement()
%%     ID = string() | undefined
%%     New_Stanza = exmpp_xml:xmlnselement()
%% @doc Set the id.

set_id(#xmlnselement{attrs = Attrs, name = Name} = Stanza, ID)
  when ID == undefined; ID == "" ->
    New_Attrs = set_id_in_attrs(Attrs, exmpp_internals:random_id(Name)),
    Stanza#xmlnselement{attrs = New_Attrs};
set_id(#xmlnselement{attrs = Attrs} = Stanza, ID) ->
    New_Attrs = set_id_in_attrs(Attrs, ID),
    Stanza#xmlnselement{attrs = New_Attrs}.

%% @spec (Attrs, ID) -> New_Attrs
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     ID = string()
%%     New_Attrs = [exmpp_xml:xmlnattribute()]
%% @doc Set the id.

set_id_in_attrs(Attrs, ID) when ID == undefined; ID == "" ->
    set_id_in_attrs(Attrs, exmpp_internals:random_id("stanza"));
set_id_in_attrs(Attrs, ID) ->
    exmpp_xml:set_attribute_in_list(Attrs, 'id', ID).

%% @spec (Stanza) -> Type | nil()
%%     Stanza = exmpp_xml:xmlnselement()
%%     Type = string()
%% @doc Return the type of the stanza.

get_type(#xmlnselement{attrs = Attrs} = _Stanza) ->
    get_type_from_attrs(Attrs).

%% @spec (Attrs) -> Type | nil()
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     Type = string()
%% @doc Return the type of the stanza.

get_type_from_attrs(Attrs) ->
    exmpp_xml:get_attribute_from_list(Attrs, 'type').

%% @spec (Stanza, Type) -> New_Stanza
%%     Stanza = exmpp_xml:xmlnselement()
%%     Type = string()
%%     New_Stanza = exmpp_xml:xmlnselement()
%% @doc Set the type of the stanza.

set_type(#xmlnselement{attrs = Attrs} = Stanza, Type) ->
    New_Attrs = set_type_in_attrs(Attrs, Type),
    Stanza#xmlnselement{attrs = New_Attrs}.

%% @spec (Attrs, Type) -> New_Attrs
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     Type = string()
%%     New_Attrs = [exmpp_xml:xmlnsattribute()]
%% @doc Set the type of the stanza.

set_type_in_attrs(Attrs, Type) ->
    exmpp_xml:set_attribute_in_list(Attrs, 'type', Type).

%% @spec (Stanza) -> Lang | nil()
%%     Stanza = exmpp_xml:xmlnselement()
%%     Lang = string()
%% @doc Return the language of the stanza.

get_lang(#xmlnselement{attrs = Attrs} = _Stanza) ->
    get_lang_from_attrs(Attrs).

%% @spec (Attrs) -> Lang | nil()
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     Lang = string()
%% @doc Return the language of the stanza.

get_lang_from_attrs(Attrs) ->
    exmpp_xml:get_attribute_in_list(Attrs, ?NS_XML, 'lang').

%% @spec (Stanza, Lang) -> New_Stanza
%%     Stanza = exmpp_xml:xmlnselement()
%%     Lang = string()
%%     New_Stanza = exmpp_xml:xmlnselement()
%% @doc Set the lang.

set_lang(#xmlnselement{attrs = Attrs} = Stanza, Lang) ->
    New_Attrs = set_lang_in_attrs(Attrs, Lang),
    Stanza#xmlnselement{attrs = New_Attrs}.

%% @spec (Attrs, Lang) -> New_Attrs
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     Lang = string()
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%% @doc Set the lang.

set_lang_in_attrs(Attrs, Lang) ->
    exmpp_xml:set_attribute_in_list(Attrs, ?NS_XML, 'lang', Lang).

% --------------------------------------------------------------------
% Common operations.
% --------------------------------------------------------------------

%% @spec (Stanza) -> Stanza_Reply
%%     Stanza = exmpp_xml:xmlnselement()
%%     Stanza_Reply = exmpp_xml:xmlnselement()
%% @doc Prepare a reply to `Stanza'.
%%
%% @see reply_from_attrs/1.

reply(#xmlnselement{attrs = Attrs} = Stanza) ->
    New_Attrs = reply_from_attrs(Attrs),
    Stanza#xmlnselement{attrs = New_Attrs}.

%% @spec (Attrs) -> New_Attrs
%%     Attrs = [exmpp_xml:xmlnsattribute()]
%%     New_Attrs = [exmpp_xml:xmlnsattribute()]
%% @doc Handles `to' and `from' attributes to prepare a reply stanza.

reply_from_attrs(Attrs) ->
    Sender = get_sender_from_attrs(Attrs),
    Recipient = get_recipient_from_attrs(Attrs),
    % Remove the `to' and `from' attributes.
    Attrs1 = exmpp_xml:remove_attribute_from_list(Attrs, 'to'),
    Attrs2 = exmpp_xml:remove_attribute_from_list(Attrs1, 'from'),
    case Sender of
        "" ->
            case Recipient of
                "" ->
                    Attrs2;
                _ ->
                    % `from' takes the old `to' value.
                    set_sender_in_attrs(Attrs2, Recipient)
            end;
        _ ->
            case Recipient of
                "" ->
                    % `to' takes the old `from' value.
                    set_recipient_in_attrs(Attrs2, Sender);
                _ ->
                    % The `to' and `from' attributes are swapped.
                    set_recipient_in_attrs(
                      set_sender_in_attrs(Attrs2, Recipient),
                      Sender)
            end
    end.

%% @spec (Stanza, Condition) -> Stanza_Reply
%%     Stanza = exmpp_xml:xmlnselement()
%%     Condition = atop()
%%     Stanza_Reply = exmpp_xml:xmlnselement()
%% @doc Prepare an error reply to `Stanza'.

reply_with_error(Stanza, Condition) ->
    Reply = reply(Stanza),
    stanza_error(Reply, Condition).

% --------------------------------------------------------------------
% Stanza-level errors.
% --------------------------------------------------------------------

standard_conditions() ->
    [
      {'bad-request',             "modify" },
      {'conflict',                "cancel" },
      {'feature-not-implemented', "cancel" },
      {'forbidden',               "auth"   },
      {'gone',                    "modify" },
      {'internal-server-error',   "wait"   },
      {'item-not-found',          "cancel" },
      {'jid-malformed',           "modify" },
      {'not-acceptable',          "modify" },
      {'not-allowed',             "cancel" },
      {'not-authorized',          "auth"   },
      {'payment-required',        "auth"   },
      {'recipient-unavailable',   "wait"   },
      {'redirect',                "modify" },
      {'registration-required',   "auth"   },
      {'remote-server-not-found', "cancel" },
      {'remote-server-timeout',   "wait"   },
      {'resource-constraint',     "wait"   },
      {'service-unavailable',     "cancel" },
      {'subscription-required',   "auth"   },
      {'unexpected-request',      "wait"   },
      {'undefined-condition',     undefined}
    ].

%% @spec (NS, Condition) -> Stanza_Error
%%     NS = atom() | string()
%%     Condition = atom()
%%     Stanza_Error = exmpp_xml:xmlnselement()
%% @doc Create an `<error/>' element based on the given `Condition'.
%%
%% A default type is set by {@link set_error_type/2} if `NS' is
%% `jabber:client' or `jabber:server'. This does not contain any text
%% element.

error(NS, Condition) ->
    error(NS, Condition, {undefined, undefined}).

%% @spec (NS, Condition, Text_Spec) -> Stanza_Error
%%     NS = atom() | string()
%%     Condition = atom()
%%     Text_Spec = {Lang, Text} | Text | undefined
%%     Lang = string() | undefined
%%     Text = string() | undefined
%%     Stanza_Error = exmpp_xml:xmlnselement()
%% @doc Create an `<error/>' element based on the given `Condition'.
%%
%% A default type is set by {@link set_error_type/2} if `NS' is
%% `jabber:client' or `jabber:server'. This does not contain any text
%% element.

error(NS, Condition, {Lang, Text}) ->
    Condition_El = #xmlnselement{
      ns = ?NS_XMPP_STANZAS,
      name = Condition,
      children = []
    },
    Error_El0 = #xmlnselement{
      ns = NS,
      name = 'error',
      children = [Condition_El]
    },
    Error_El = case Text of
        undefined ->
            Error_El0;
        _ ->
            Text_El0 = #xmlnselement{
              ns = ?NS_XMPP_STANZAS,
              name = 'text',
              children = []
            },
            Text_El = case Lang of
                undefined ->
                    Text_El0;
                _ ->
                    exmpp_xml:set_attribute(Text_El0, ?NS_XML, 'lang', Lang)
            end,
            exmpp_xml:append_child(Error_El0, Text_El)
    end,
    set_error_type_from_condition_in_error(Error_El, Condition);
error(NS, Condition, Text) ->
    error(NS, Condition, {undefined, Text}).

%% @spec (Stanza, Error) -> Stanza_Error
%%     Stanza = exmpp_xml:xmlnselement()
%%     Error = exmpp_xml:xmlnselement()
%%     Stanza_Error = exmpp_xml:xmlnselement()
%% @doc Transform `Stanza' in a stanza error.
%%
%% The `type' attribute is set and an error condition is added. The
%% caller is still responsible to set or modify the `to' attribute
%% correctly.
%%
%% @see error/2.
%% @see error/3.

stanza_error(Stanza, Error) ->
    Stanza_Error = exmpp_xml:append_child(Stanza, Error),
    set_type(Stanza_Error, "error").

%% @spec (Stanza, Error) -> Stanza_Error
%%     Stanza = exmpp_xml:xmlnselement()
%%     Error = exmpp_xml:xmlnselement()
%%     Stanza_Error = exmpp_xml:xmlnselement()
%% @doc Transform `Stanza' in a stanza error.
%%
%% Previous child elements from `Stanza' are not kept.
%%
%% @see stanza_error/2.

stanza_error_without_original(Stanza, Error) ->
    Stanza_Error = exmpp_xml:set_children(Stanza, [Error]),
    set_type(Stanza_Error, "error").

%% @spec (Stanza) -> bool()
%%     Stanza = exmpp_xml:xmlnselement()
%% @doc Tell if the stanza transports an error.

is_stanza_error(Stanza) ->
    case get_type(Stanza) of
        "error" -> true;
        _       -> false
    end.

%% @spec (Stanza) -> Type
%%     Stanza = exmpp_xml:xmlnselement()
%%     Type = string()
%% @throws {stanza_error, error_type, no_error_element_found, Stanza}
%% @doc Return the type of the error element.

get_error_type(Stanza) ->
    case get_error(Stanza) of
        undefined ->
            throw({stanza_error, error_type, no_error_element_found, Stanza});
        Error ->
            get_error_type_from_error(Error)
    end.

get_error_type_from_error(Error) ->
    exmpp_xml:get_attribute(Error, 'type').

%% @spec (Stanza, Type) -> New_Stanza
%%     Stanza = exmpp_xml:xmlnselement()
%%     Type = string()
%%     New_Stanza = exmpp_xml:xmlnselement()
%% @throws {stanza_error, error_type, no_error_element_found, Stanza}
%% @doc Set the type of the error element.

set_error_type(Stanza, Type) ->
    case get_error(Stanza) of
        undefined ->
            throw({stanza_error, error_type, no_error_element_found, Stanza});
        Error ->
            New_Error = set_error_type_in_error(Error, Type),
            exmpp_xml:replace_child(Stanza, Error, New_Error)
    end.

set_error_type_in_error(Error, Type) ->
    exmpp_xml:set_attribute(Error, 'type', Type).

%% @spec (Stanza, Condition) -> New_Stanza
%%     Stanza = exmpp_xml:xmlnselement()
%%     Condition = atom()
%%     New_Stanza = exmpp_xml:xmlnselement()
%% @throws {stanza_error, error_type, no_error_element_found, Stanza} |
%%         {stanza_error, error_type, invalid_condition, {NS, Condition}}
%% @doc Set the type of the error element, based on the given condition.
%%
%% If the condition is `undefined-condition', the type is unchanged.

set_error_type_from_condition(Stanza, Condition) ->
    case get_error(Stanza) of
        undefined ->
            throw({stanza_error, error_type, no_error_element_found, Stanza});
        Error ->
            New_Error = set_error_type_from_condition_in_error(Error,
              Condition),
            exmpp_xml:replace_child(Stanza, Error, New_Error)
    end.

set_error_type_from_condition_in_error(#xmlnselement{ns = NS} = Error,
  Condition) when NS == ?NS_JABBER_CLIENT; NS == ?NS_JABBER_SERVER ->
    case lists:keysearch(Condition, 1, standard_conditions()) of
        {value, {_, undefined}} ->
            Error;
        {value, {_, Type}} ->
            set_error_type_in_error(Error, Type);
        false ->
            throw({stanza_error, error_type, invalid_condition,
                {NS, Condition}})
    end;
set_error_type_from_condition_in_error(Error, _Condition) ->
    Error.

%% @spec (Stanza) -> Condition | undefined
%%     Stanza = exmpp_xml:xmlnselement()
%%     Condition = atom()
%% @throws {stanza_error, condition, no_error_element_found, Stanza} |
%%         {stanza_error, condition, no_condition_found, Error}
%% @doc Return the child element name corresponding to the stanza error
%% condition.
%%
%% If the namespace isn't neither `jabber:client' nor `jabber:server',
%% the name of the first child is returned.

get_condition(Stanza) ->
    case get_error(Stanza) of
        undefined ->
            throw({stanza_error, condition, no_error_element_found, Stanza});
        Error ->
            get_condition_in_error(Error)
    end.

get_condition_in_error(#xmlnselement{ns = NS} = Error)
  when NS == ?NS_JABBER_CLIENT; NS == ?NS_JABBER_SERVER ->
    case exmpp_xml:get_element_by_ns(Error, ?NS_XMPP_STANZAS) of
        undefined ->
            % This <error/> element is invalid because the condition must be
            % present (and first).
            throw({stanza_error, condition, no_condition_found, Error});
        #xmlnselement{name = 'text'} ->
            % Same as above.
            throw({stanza_error, condition, no_condition_found, Error});
        #xmlnselement{name = Condition} ->
            Condition
    end;
get_condition_in_error(#xmlnselement{children = [First | _]} = _Error) ->
    First#xmlnselement.name;
get_condition_in_error(_Error) ->
    undefined.

%% @spec (Stanza) -> Text | undefined
%%     Stanza = exmpp_xml:xmlnselement()
%%     Text = string()
%% @throws {stanza_error, text, no_error_element_found, Stanza}
%% @doc Return the text that describes the error.
%%
%% If there is no `<text/>' element, an empty string is returned.

get_text(Stanza) ->
    case get_error(Stanza) of
        undefined ->
            throw({stanza_error, text, no_error_element_found, Stanza});
        Error ->
            get_text_in_error(Error)
    end.

get_text_in_error(#xmlnselement{ns = NS} = Error)
  when NS == ?NS_JABBER_CLIENT; NS == ?NS_JABBER_SERVER ->
    case exmpp_xml:get_element_by_name(Error, ?NS_XMPP_STANZAS, 'text') of
        undefined -> undefined;
        Text      -> exmpp_xml:get_cdata(Text)
    end;
get_text_in_error(Error) ->
    case exmpp_xml:get_element_by_name(Error, 'text') of
        undefined -> undefined;
        Text      -> exmpp_xml:get_cdata(Text)
    end.