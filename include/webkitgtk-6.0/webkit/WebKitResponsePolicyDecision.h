/*
 * Copyright (C) 2012 Igalia S.L.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#if !defined(__WEBKIT_H_INSIDE__) && !defined(BUILDING_WEBKIT)
#error "Only <webkit/webkit.h> can be included directly."
#endif

#ifndef WebKitResponsePolicyDecision_h
#define WebKitResponsePolicyDecision_h

#include <glib-object.h>
#include <webkit/WebKitDefines.h>
#include <webkit/WebKitPolicyDecision.h>
#include <webkit/WebKitURIResponse.h>
#include <webkit/WebKitURIRequest.h>

G_BEGIN_DECLS

#define WEBKIT_TYPE_RESPONSE_POLICY_DECISION            (webkit_response_policy_decision_get_type())
#define WEBKIT_RESPONSE_POLICY_DECISION(obj)            (G_TYPE_CHECK_INSTANCE_CAST((obj), WEBKIT_TYPE_RESPONSE_POLICY_DECISION, WebKitResponsePolicyDecision))
#define WEBKIT_RESPONSE_POLICY_DECISION_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST((klass),  WEBKIT_TYPE_RESPONSE_POLICY_DECISION, WebKitResponsePolicyDecisionClass))
#define WEBKIT_IS_RESPONSE_POLICY_DECISION(obj)         (G_TYPE_CHECK_INSTANCE_TYPE((obj), WEBKIT_TYPE_RESPONSE_POLICY_DECISION))
#define WEBKIT_IS_RESPONSE_POLICY_DECISION_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE((klass),  WEBKIT_TYPE_RESPONSE_POLICY_DECISION))
#define WEBKIT_RESPONSE_POLICY_DECISION_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS((obj),  WEBKIT_TYPE_RESPONSE_POLICY_DECISION, WebKitResponsePolicyDecisionClass))

typedef struct _WebKitResponsePolicyDecision        WebKitResponsePolicyDecision;
typedef struct _WebKitResponsePolicyDecisionClass   WebKitResponsePolicyDecisionClass;
typedef struct _WebKitResponsePolicyDecisionPrivate WebKitResponsePolicyDecisionPrivate;

struct _WebKitResponsePolicyDecision {
    WebKitPolicyDecision parent;

    /*< private >*/
    WebKitResponsePolicyDecisionPrivate *priv;
};

struct _WebKitResponsePolicyDecisionClass {
    WebKitPolicyDecisionClass parent_class;

    /*< private >*/
    void (*_webkit_reserved0) (void);
    void (*_webkit_reserved1) (void);
    void (*_webkit_reserved2) (void);
    void (*_webkit_reserved3) (void);
};

WEBKIT_API GType
webkit_response_policy_decision_get_type                    (void);

WEBKIT_API WebKitURIRequest *
webkit_response_policy_decision_get_request                 (WebKitResponsePolicyDecision *decision);

WEBKIT_API WebKitURIResponse *
webkit_response_policy_decision_get_response                (WebKitResponsePolicyDecision *decision);

WEBKIT_API gboolean
webkit_response_policy_decision_is_mime_type_supported      (WebKitResponsePolicyDecision *decision);

WEBKIT_API gboolean
webkit_response_policy_decision_is_main_frame_main_resource (WebKitResponsePolicyDecision* decision);

G_END_DECLS

#endif
