console.log('Loaded sc sidebar plugin');
var SidebarLogic = {};
SidebarLogic.init = function () {
    console.log('Sidebar plugin initialized');
    var link = document.createElement('link');
    link.rel = 'stylesheet';
    link.type = 'text/css';
    //link.href = 'https://flow-customization-1042-dev-ed--c.visualforce.com/resource/' + (new Date()).getTime() + '/sidebar_css/css/main.css';
    //link.href = 'https://telstrab2b--liverpoolc--c.visualforce.com/resource/' + (new Date()).getTime() + '/sidebar_css/css/main.css';

    if (window.location.href.includes('partners')) {
        link.href = window.location.origin + '/partners/resource/' + (new Date()).getTime() + '/sidebar_css/css/main.css';
    } else {
        link.href = window.location.origin + '/resource/' + (new Date()).getTime() + '/sidebar_css/css/main.css';	
    }

    // Get HTML head element to append
    // link element to it
    document.getElementsByTagName('head')[0].appendChild(link);
    function financial(x) {
        if (typeof x === 'undefined') {
            return '-';
        }
        return Number.parseFloat(x).toFixed(3);
    }
    function percentage(sales, list) {
        const decimalOff = (sales == 0) ? 0 : Math.floor(((list - sales) * 100) / list);
        if (decimalOff === 0 || decimalOff === Infinity || decimalOff === -Infinity || decimalOff < 0) {
            return 0;
        }
        return decimalOff;
    }
    function paginateArray(array, page_number, page_size) {
        --page_number; // because pages logically start with 1, but technically with 0
        return array.slice(page_number * page_size, (page_number + 1) * page_size);
    }
    async function createSidebarHtml(cart, page, pageSize) {
        function getSelectedPage() {
            try {
                const page = document.querySelectorAll('#pricing-summary-pagination .pagination-buttons-wrapper > button.pager-selected')[0].innerText;
                return parseInt(page);
            } catch (e) {
                return 1;
            }
        }
        function getSelectedPageSize() {
            try {
                const pageSize = document.querySelectorAll('#pricing-summary-pagination .slds-select')[0].selectedOptions[0].value;
                return parseInt(pageSize);
            } catch (e) {
                return 10;
            }
        }
        //to display promotional items we need to give them "carrier configurations"
        //we only need guid, isRelatedProduct and configurationName
        function getPromotionalItemsConfigurations(cartItems, allConfigs) {
            let promotionalConfigs = [];
            for (const cartItem of cartItems) {
                let config = allConfigs.find(config => config.guid === cartItem.id);
                //if not found, then we assume it is promotional item so create dummy config
                if (!config) {
                    promotionalConfigs.push({
                        guid: cartItem.id,
                        isRelatedProduct: false,
                        configurationName: cartItem.catalogueItemId
                    })
                }
            }
            return promotionalConfigs;
        }
        let solution;
        try {
            //console.log(new Date().toISOString() + ' getting solution');
            solution = await CS.SM.getActiveSolution();
            //console.log(new Date().toISOString() + ' got solution');
        } catch (e) {
            throw 'No solution found!';
        }
        page = page || getSelectedPage();
        pageSize = pageSize || getSelectedPageSize();
        const allSolutionConfigurations = PRE_Logic.getSolutionConfigurations(solution);
        //to display promotional items we need to give them "carrier configurations"
        const promotionalConfigs = getPromotionalItemsConfigurations(cart.items, allSolutionConfigurations);
        const combinedConfigs = promotionalConfigs.concat(allSolutionConfigurations);//merge them and let the added ones are on top
        const solutionConfigurations = paginateArray(combinedConfigs, page, pageSize);
        //console.log('numOfConfigs ' + solutionConfigurations.length);
        const numOfPages = Math.ceil(allSolutionConfigurations.length / 10);
        const tableRows = (cartItems) => {
            return solutionConfigurations.map(config => {
                if (config.isRelatedProduct) {
                    return;
                }
                const configName = config.configurationName;
                //AB payload reduction fix start
                let cartItem;
                //find matching cart item (searches parent and child items)
                for (let item of cartItems) {
                	if (item.id === config.guid) {
                		cartItem = item;
                		break;
                	} else {
                		//not current item, check its child items
                		cartItem = item.childItems.selectedRelatedProducts.find(rp => rp.id === config.guid);
                		if (cartItem) {
                			break; //found it so stop searching
                		}
                	}
                };
                cartItem = cartItem || {pricing: {}};
                //AB payload reduction fix end
                const totalListOneOffPrice = financial(cartItem.pricing.totalListOneOffPrice);
                const totalListRecurringPrice = financial(cartItem.pricing.totalListRecurringPrice);
                const oneOffPercentage = percentage(cartItem.pricing.totalSalesOneOffPrice, cartItem.pricing.totalListOneOffPrice);
                const recurringPercentage = percentage(cartItem.pricing.totalSalesRecurringPrice, cartItem.pricing.totalListRecurringPrice);
                const totalSalesOneOffPrice = financial(cartItem.pricing.totalSalesOneOffPrice);
                const totalSalesRecurringPrice = financial(cartItem.pricing.totalSalesRecurringPrice);
                const quantity = cartItem.quantity || 1;
                const item = {
                    configName: configName,
                    totalListOneOffPrice: totalListOneOffPrice,
                    totalListRecurringPrice: totalListRecurringPrice,
                    totalSalesOneOffPrice: totalSalesOneOffPrice,
                    totalSalesRecurringPrice: totalSalesRecurringPrice,
                    pricing: cartItem.pricing,
                    quantity: quantity
                }
                return `
				<div class="pricing-sidebar-table-row-wrapper" data-row-item='${JSON.stringify(item)}' onmouseover="CS.drawOnHoverPopup(this)">
					<div class="pricing-sidebar-table-row">
						<div>${configName}</div>
						<div></div>
						<div>
							<span>List Pr.</span>
							<span>${totalListRecurringPrice}</span> <!-- recurring list price -->
						</div>
						<div>${totalListOneOffPrice}</div> <!-- oneOff list price -->
					</div>
					<div class="pricing-sidebar-table-row active">
                        <div>x${quantity}</div>
						<div>
							${(
                        oneOffPercentage ?
                            '<button class="button-primary"><b>' + oneOffPercentage + '%</b> off</button>'
                            : (
                                recurringPercentage ? '<button class="button-primary"><b>' + recurringPercentage + '%</b> off</button>' :
                                    '<button style="visibility: hidden;" class="button-primary"><b>0%</b> off</button>'
                            )
                    )}
						</div>
						<div>
							<span>Sales Pr.</span>
							<span>${totalSalesRecurringPrice}</span> <!-- recurring sales price -->
						</div>
						<div>${totalSalesOneOffPrice}</div> <!-- oneOff sales price -->
					</div>
				</div>`;
            }).filter(Boolean).join(' ');
        }
        const sidebarTable =
            `<div class="pricing-sidebar-table">
				<div class="pricing-sidebar-table-head">
					<h5>Product</h5>
					<h5>Discount</h5>
					<h5>Reccuring</h5>
					<h5>One Off</h5>
				</div>
				<div class="pricing-sidebar-table-rows">
					${tableRows(cart.items)}
				</div>
			</div>`;
        const pricingDetailsButton =
            `<div class="section">
				<!-- <button class="button button-lg" id="pricing-details-button">Pricing Details Overview</button> -->
			</div>`;
        const pagination =
            `
			<nav id="pricing-summary-pagination" aria-label="pagination" class="pagination-wrapper ng-star-inserted">
				<div class="pagination-buttons-wrapper">
					${(page - 1 === 0) ?
                `<button aria-label="previous page" class="cs-btn navigation-button icon-down" disabled ></button>` :
                `<button aria-label="previous page" class="cs-btn navigation-button icon-down" onclick="CS.onClickPaginate(${page - 1})"></button>`
            }
					${[...Array(numOfPages + 1).keys()].map((num) => {
                if (num === 0) {
                    return;
                }
                if ((num >= (page - 2)) && (num <= (page + 2))) {
                    if (num === page) {
                        return `<button class="cs-btn pager-button ng-star-inserted pager-selected" onclick="CS.onClickPaginate(${num})">${num}</button>`
                    } else {
                        return `<button class="cs-btn pager-button ng-star-inserted" onclick="CS.onClickPaginate(${num})">${num}</button>`
                    }
                }
            }).filter(Boolean).join(' ')
            }
					${(page + 1 > numOfPages) ?
                `<button aria-label="next page" class="cs-btn navigation-button icon-down" disabled ></button>` :
                `<button aria-label="next page" class="cs-btn navigation-button icon-down" onclick="CS.onClickPaginate(${page + 1})"></button>`
            }
				</div>
				<!--
				<div class="slds-form-element__control page-size-container ng-star-inserted">
					<div aria-label="items per page" class="slds-select_container">
						<select class="slds-select ng-untouched ng-pristine ng-valid">
							<option value="10">10</option>
							<option value="25">25</option>
							<option value="50">50</option>
							<option value="100">100</option>
						</select>
					</div>
				</div>
				-->
			</nav>
			`;
        const sidebar =
            `${sidebarTable}
			${pagination}`;
        return sidebar;
    }
    function onClickPaginate(num) {
        drawSidebar(CS.currentPRECart, num);
    }
    async function drawSidebar(cart, page, pageSize) {
        try {
            // remove warning message
            document.querySelectorAll('.pricing-summary-wrapper .warning-message')[0].outerHTML = '';
        } catch (e) { }
        try {
            const sidebarHtml = await createSidebarHtml(cart || {}, page, pageSize);
            //console.log('start setting inner html: ' + new Date().toISOString());
            document.querySelectorAll('.price-summary-table .item-list-wrapper')[0].innerHTML = '';
            document.querySelectorAll('.price-summary-table .item-list-wrapper')[0].innerHTML = sidebarHtml;
            //console.log('done  setting inner html: ' + new Date().toISOString());
        } catch (e) {
            console.warn(e);
        }
        // a container for the modal to be displayed in, should be hidden
        try {
            const modalContainerWrapper = document.createElement('div');
            modalContainerWrapper.style.position = 'relative';
            modalContainerWrapper.className = 'modal-container-wrapper';
            const modalContainer = document.createElement('div');
            modalContainer.style.width = '500px';
            modalContainer.style.height = '100%';
            modalContainer.style.position = 'absolute';
            modalContainer.style.top = '0';
            modalContainer.style.right = '0';
            modalContainer.style.display = 'none';
            // modalContainer.style.pointerEvents = 'none';
            modalContainer.className = 'modal-container';
            modalContainerWrapper.appendChild(modalContainer);
            // add the modal-container-wrapper only if it does not exist
            if (!document.querySelectorAll('.modal-container-wrapper').length) {
                const sibling = document.querySelectorAll('.pricing-summary-wrapper')[0];
                const parent = sibling.parentElement;
                parent.insertBefore(modalContainerWrapper, sibling);
            }
        } catch (e) {
            console.error(e);
        }
    }
    CS.drawSidebar = drawSidebar;
    CS.drawOnHoverPopup = drawOnHoverPopup;
    CS.hideOnHoverPopup = hideOnHoverPopup;
    CS.onClickPaginate = onClickPaginate;
    /*********
     * POPUP *
     *********/
    function hideOnHoverPopup() {
        document.querySelectorAll('.modal-container')[0].style.display = 'none';
        document.querySelectorAll('.modal-container')[0].innerHTML = '';
    }
    function drawOnHoverPopup(element) {
        const item = JSON.parse(element.attributes["data-row-item"].value);
        const discounts = item && item.pricing && item.pricing.discounts || [];
        //discount structure is diferent when we have multiple/parallel discounts
        var flatDiscounts = [];
        discounts.forEach(disc => {
            if (disc.type) {
                flatDiscounts.push(disc);
            } else if (disc.memberDiscounts) {
                flatDiscounts = flatDiscounts.concat(disc.memberDiscounts);
            }
        })
        const discountsHtml = flatDiscounts.filter(discount => {
            return discount.type !== 'override' && discount.type !== 'init'; // override and init prices are used to determine base pricing
        }).map(discount => {
            return `
				<div class="pricing-sidebar-table-row active">
					<div><p style="white-space:normal;">${RetrievedData.prToPrgMap[discount.source] || discount.source}${eval('if(discount.duration!=null) { var dur = "( valid for "+discount.duration+" months )"; dur; } else { " " }')}</p></div>
					<div></div>
					<div>
						${discount.type === 'percentage' ?
                    '<button class="button-primary"><b>' + discount.amount + '%</b> off</button>' :
                    '<button style="visibility: hidden;" class="button-primary"></button>'
                }
					</div>
					${discount.chargeType === 'recurring' ?
                    (discount.type === 'percentage' ? '<div>-</div><div>-</div>' : '<div>-' + financial(discount.amount) + '</div><div>-</div>') :
                    '<div>-</div><div>' + financial(discount.amount) + '</div>'
                }
				</div>`;
        }).join('');
        
        const chargesHtml = flatDiscounts.filter(discount => {
            return (discount.type === 'override' && discount.discountPrice === 'sales') || discount.type === 'init'; // override and init prices are used to determine base pricing
        }).map(discount => {
            return `
				<div class="pricing-sidebar-table-row active">
					<div><p style="white-space:normal;">${discount.description}${eval('if(discount.duration!=null) { var dur = "( valid for "+discount.duration+" months )"; dur; } else { " " }')}</p></div>
					<div></div>
					<div>
						${discount.type === 'percentage' ?
                    '<button class="button-primary"><b>' + discount.amount + '%</b> off</button>' :
                    '<button style="visibility: hidden;" class="button-primary"></button>'
                }
					</div>
					${discount.chargeType === 'recurring' ?
                    (discount.type === 'percentage' ? '<div>-</div><div>-</div>' : '<div>' + financial(discount.amount) + '</div><div>-</div>') :
                    '<div></div><div>' + financial(discount.amount) + '</div>'
                }
				</div>`;
        }).join('');

        const prodCharge = chargesHtml === "" ? 
            `<div class="pricing-sidebar-table-row">
                <div style="white-space:normal;">${item.configName}</div>
                <div>x${item.quantity}</div>
				<div></div>
				<div>${item.totalListRecurringPrice}</div>
				<div>${item.totalListOneOffPrice}</div>
			</div>` : "";

        const modal = `
		<!-- Pricing Modal -->
		<div class="pricing-modal" onmouseleave="CS.hideOnHoverPopup()">
			<div class="pricing-modal-head">
				<h3>Pricing Details Drilldown</h3>
			</div>
			<div class="pricing-modal-table">
				<div class="pricing-sidebar-table">
					<div class="pricing-sidebar-table-head">
						<h5>Description</h5>
						<h5>Quantity</h5>
						<h5>Discount</h5>
						<h5>Reccuring</h5>
						<h5>One Off</h5>
					</div>
					<div class="pricing-sidebar-table-rows">
					    <!-- product charge displayed only if no charges -->
						${prodCharge}
						<!--<div class="pricing-sidebar-table-row">
							<div class="pricing-sidebar-table-total">Charges subtotal</div>
							<div></div>
							<div></div>
							<div class="pricing-sidebar-table-total">${item.totalListRecurringPrice}</div>
							<div class="pricing-sidebar-table-total">${item.totalListOneOffPrice}</div>
						</div>-->
						${chargesHtml}
						<!-- DISCOUNTS -->
						${discountsHtml}
						<div class="pricing-sidebar-table-row">
							<div class="pricing-sidebar-table-total">Totals</div>
							<div></div>
							<div></div>
							<div class="pricing-sidebar-table-total">${item.totalSalesRecurringPrice}</div> <!-- recurring sales price -->
							<div class="pricing-sidebar-table-total">${item.totalSalesOneOffPrice}</div> <!-- one off sales price -->
						</div>
						<!-- For Total(Inc. GST) -->
						<div class="pricing-sidebar-table-row">
							<div class="pricing-sidebar-table-total">Totals(Inc. GST)</div>
							<div></div>
							<div></div>
							<div class="pricing-sidebar-table-total">${eval('if(!isNaN(item.totalSalesRecurringPrice)) { var tgstR = item.totalSalesRecurringPrice*1.1; tgstR.toFixed(3); } else { "-" }')}</div> <!-- recurring sales price -->
							<div class="pricing-sidebar-table-total">${eval('if(!isNaN(item.totalSalesOneOffPrice)) { var tgstOf = item.totalSalesOneOffPrice*1.1; tgstOf.toFixed(3); } else { "-" }')}</div> <!-- one off sales price -->
						</div>
					</div>
				</div>
			</div>
			<div class="pricing-modal-footer">
				<button class="button" id="pricing-modal-close" onclick="CS.hideOnHoverPopup()">Close</button>
			</div>
		</div>`;
        // display after creating html
        document.querySelectorAll('.modal-container')[0].style.display = 'block';
        document.querySelectorAll('.modal-container')[0].innerHTML = modal;
    }
};
