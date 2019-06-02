# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils
inherit git-r3

EGIT_REPO_URI="https://github.com/kpet/clvk"
EGIT_SUBMODULES=( '*' '-talvos' '-opencl-conformance-tests' '-vulkan-headers' )

DESCRIPTION="Experimental implementation of OpenCL on Vulkan"
HOMEPAGE="https://github.com/kpet/clvk"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="test"

DEPEND="dev-util/vulkan-headers
	>=dev-util/cmake-3.9
"
RDEPEND="media-libs/vulkan-loader"
BDEPEND=""

src_unpack(){
	git-r3_src_unpack
	"${S}"/external/clspv/utils/fetch_sources.py --deps clang llvm
}

CMAKE_BUILD_TYPE=Release

src_configure(){
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DCLVK_BUILD_TESTS=$(usex test)
	)

	cmake-utils_src_configure
}

src_install(){
	cmake-utils_src_install

	dobin "${BUILD_DIR}/clspv"

	local vendor_dir=usr/$(get_libdir)/OpenCL/vendors/clvk
	dodir "${vendor_dir}"
	insinto "${vendor_dir}"
	doins "${BUILD_DIR}/libOpenCL.so.0.1"
	dosym "/${vendor_dir}/libOpenCL.so.0.1" "${vendor_dir}/libOpenCL.so"
	dosym "/${vendor_dir}/libOpenCL.so.0.1" "${vendor_dir}/libOpenCL.so.1"
	dosym "/${vendor_dir}/libOpenCL.so.0.1" "${vendor_dir}/libOpenCL.so.1.2"
}

pkg_postinst() {
	eselect opencl set --use-old clvk
}
