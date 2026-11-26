PORTNAME=	krdp
DISTVERSION=	${KDE_PLASMA_VERSION}
CATEGORIES=	net kde kde-plasma

MAINTAINER=	kde@FreeBSD.org
COMMENT=	RDP server for KDE Plasma
WWW=		https://invent.kde.org/plasma/krdp

LICENSE=	LGPL21 LGPL3
LICENSE_COMB=	dual

BUILD_DEPENDS=	evdev-proto>0:devel/evdev-proto
LIB_DEPENDS=	libei.so:x11/libei \
		libfreerdp3.so:net/freerdp3 \
		libfreerdp-server3.so:net/freerdp3 \
		libqt6keychain.so:security/qtkeychain \
		libwinpr3.so:net/freerdp3 \
		libxkbcommon.so:x11/libxkbcommon
RUN_DEPENDS=	plasma6-xdg-desktop-portal-kde>0:deskutils/plasma6-xdg-desktop-portal-kde

USES=		cmake compiler:c++20-lang gettext kde:6 pkgconfig qt:6 tar:xz
USE_KDE=	config coreaddons crash dbusaddons guiaddons i18n kcmutils \
		kirigami-addons statusnotifieritem \
		ecm:build plasma-wayland-protocols:build
# KDE Plasma
USE_KDE+=	kpipewire
USE_QT=		base declarative wayland

CMAKE_OFF=	BUILD_TESTING

# std::jthread and std::stop_token are experimental in libc++ < 20
CXXFLAGS+=	-fexperimental-library

.include <bsd.port.mk>
