Name:       harbour-asteroid-heliograph
Summary:    Heliograph, a text banner
Version:    1.0.1
Release:    1
License:    GPLv3+
URL:        https://github.com/moWerk/asteroid-heliograph
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   qt5-qtgraphicaleffects
Requires:   libkeepalive
Requires:   nemo-qml-plugin-systemsettings
Requires:   qt5-qtdeclarative-import-sensors
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils
BuildRequires:  qt5-qttools-linguist

%description
Heliograph shows a message as a big scrolling banner, to be read from
across a room or a street. Ready made messages in categories, plus your
own in custom.txt. Ported from AsteroidOS.

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5
%make_build

%install
%qmake5_install
desktop-file-install --delete-original \
    --dir %{buildroot}%{_datadir}/applications \
    %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
